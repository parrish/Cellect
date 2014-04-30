module Cellect
  module Adapters
    class Default
      # Return a list of projects to load in the form:
      #   [{
      #     'id' => 123,
      #     'name' => 'foo',
      #     'prioritized' => false,
      #     'pairwise' => false,
      #     'grouped' => false
      #   }, ...]
      def project_list
        raise NotImplementedError
      end
      
      # Load the data for a project, this method:
      #   Accepts a project
      #   Returns an array of hashes in the form:
      #   {
      #     'id' => 123,
      #     'priority' => 0.123,
      #     'group_id' => 456
      #   }
      def load_data_for(project)
        raise NotImplementedError
      end
      
      def load_user(id)
        raise NotImplementedError
      end
      
      def load_projects
        project_list.each{ |project_info| load_project project_info }
      end
      
      def load_project(args, async: true)
        info = if args.is_a?(Hash)
          args
        elsif args.is_a?(String)
          project_list.select{ |h| h['name'] == args }.first
        else
          raise ArgumentError
        end
        
        if async
          project_for(info).async.load_data
        else
          project_for(info).load_data
        end
      end
      
      def project_for(opts = { })
        project_klass = opts.fetch('grouped', false) ? GroupedProject : Project
        project_klass[opts['name'], pairwise: opts['pairwise'], prioritized: opts['prioritized']]
      end
    end
  end
end
