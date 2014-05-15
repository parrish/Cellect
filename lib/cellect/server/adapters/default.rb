module Cellect
  module Server
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
        def load_data_for(project_name)
          raise NotImplementedError
        end
        
        # Load seen ids for a user, this method:
        #   Accepts a project_name, and a user id
        #   Returns an array in the form:
        #   [1, 2, 3]
        def load_user(project_name, id)
          raise NotImplementedError
        end
        
        def load_projects
          project_list.each{ |project_info| load_project project_info }
        end
        
        def load_project(args)
          info = if args.is_a?(Hash)
            args
          elsif args.is_a?(String)
            project_list.select{ |h| h['name'] == args }.first
          else
            raise ArgumentError
          end
          
          project_for info
        end
        
        def project_for(opts = { })
          project_klass = opts.fetch('grouped', false) ? GroupedProject : Project
          project_klass[opts['name'], pairwise: opts['pairwise'], prioritized: opts['prioritized']]
        end
      end
    end
  end
end