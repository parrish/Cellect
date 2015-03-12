module Cellect
  module Server
    class Workflow
      include Celluloid
      
      attr_accessor :name, :users, :subjects, :state
      attr_accessor :pairwise, :prioritized
      
      # Look up and/or load a workflow
      def self.[](name)
        Cellect::Server.adapter.load_workflows(name) unless Actor[name]
        Actor[name].actors.first
      end
      
      # Load a workflow
      def self.[]=(name, opts)
        Actor[name] = supervise name, pairwise: opts['pairwise'], prioritized: opts['prioritized']
      end
      
      # The names of all workflows currently loaded
      def self.names
        actor_names = Celluloid.actor_system.registry.names.collect &:to_s
        workflow_actors = actor_names.select{ |key| key =~ /^workflow_/ }
        workflow_actors.collect{ |name| name.sub(/^workflow_/, '').to_sym }
      end
      
      # All currently loaded workflows
      def self.all
        names.collect{ |name| Workflow[name] }
      end
      
      # Sets up a new workflow and starts the data loading
      def initialize(name, pairwise: false, prioritized: false)
        self.name = name
        self.users = { }
        self.pairwise = !!pairwise
        self.prioritized = !!prioritized
        self.subjects = set_klass.new
        load_data
      end
      
      # Loads subjects from the adapter
      def load_data
        self.state = :initializing
        self.subjects = set_klass.new
        Cellect::Server.adapter.load_data_for(name).each do |hash|
          subjects.add hash['id'], hash['priority']
        end
        self.state = :ready
      end
      
      # Look up and/or load a user
      def user(id)
        self.users[id] ||= User.supervise id, workflow_name: name
        users[id].actors.first
      end
      
      # Get unseen subjects for a user
      def unseen_for(user_id, limit: 5)
        subjects.subtract user(user_id).seen, limit
      end
      
      # Add subjects to a users seen set
      def add_seen_for(user_id, *subject_ids)
        [subject_ids].flatten.compact.each do |subject_id|
          user(user_id).seen.add subject_id
        end
      end
      
      # Unload a user
      def remove_user(user_id)
        removed = self.users.delete user_id
        removed.terminate if removed
      end
      
      # Get a sample of subjects for a user
      # 
      # Accepts a hash in the form:
      #   {
      #     user_id: 123,
      #     limit: 5
      #   }
      def sample(opts = { })
        if opts[:user_id]
          unseen_for opts[:user_id], limit: opts[:limit]
        else
          subjects.sample opts[:limit]
        end
      end
      
      # Adds or updates a subject
      # 
      # Accepts a hash in the form:
      # {
      #   subject_id: 1,
      #   priority: 0.5  # (if the workflow is prioritized)
      # }
      def add(opts = { })
        if prioritized?
          subjects.add opts[:subject_id], opts[:priority]
        else
          subjects.add opts[:subject_id]
        end
      end
      
      # Removes a subject
      # 
      # Accepts a hash in the form:
      # {
      #   subject_id: 1
      # }
      def remove(opts = { })
        subjects.remove opts[:subject_id]
      end
      
      def pairwise?
        !!pairwise
      end
      
      def prioritized?
        !!prioritized
      end
      
      def grouped?
        false
      end
      
      def ready?
        state == :ready
      end
      
      # Provide a lookup for matching sets to workflow criteria
      SET_KLASS = {
        # priority, pairwise
        [    false, false  ] => DiffSet::RandomSet,
        [    false, true   ] => DiffSet::PairwiseRandomSet,
        [     true, false  ] => DiffSet::PrioritySet,
        [     true, true   ] => DiffSet::PairwisePrioritySet
      }
      
      # Looks up the set class
      def set_klass
        SET_KLASS[[prioritized, pairwise]]
      end
      
      # General information about this workflow
      def status
        {
          state: state,
          grouped: false,
          prioritized: prioritized,
          pairwise: pairwise,
          subjects: subjects.size,
          users: users.length
        }
      end
    end
  end
end
