function [ results ] = ReadResults( root_path, filename, str_split )
    path = strcat([root_path 'results\']);
    if strcmp(filename,'')        
        listing = dir(path);
        results_filenames = {listing.name};
        results_filenames = {results_filenames{1,3:end}};
    else
        results_filenames = {filename};
    end
    
    ix_result = 1;
    results = {};
    for curr_file=1:size(results_filenames,2)
        if length(results_filenames{curr_file}) > 7 && strcmp(results_filenames{curr_file}(1:6),'result')
            result_fid = fopen(strcat([path results_filenames{curr_file}]),'r');
            %read header
            result.model = '';
            result.task = '';
            result.pcl = '';
            result.n_proj = 0;
            result.n_iter = 0;
            line = fgetl(result_fid);
            while ~strcmp(line,'end_header')
                result.model = ReadResultField( str_split, result.model, line, 'model', 'string' );
                result.task = ReadResultField( str_split, result.task, line, 'task', 'string' );
                result.pcl = ReadResultField( str_split, result.pcl, line, 'pcl', 'string' );
                result.n_proj = ReadResultField( str_split, result.n_proj, line, 'n_proj', 'number' );
                result.n_iter = ReadResultField( str_split, result.n_iter, line, 'n_iter', 'number' );
                line = fgetl(result_fid);
            end  
            %read results   
            result.projections = {};
            for curr_projection=1:result.n_proj
                projection.n_best_chains = 0; 
                projection.size_error_message = 0;
                projection.error_message = '';
                projection.best_chains = {};
                while ~strcmp(line,'result')
                    line = fgetl(result_fid);
                end
                line = fgetl(result_fid);
                projection.n_best_chains = ReadResultField( str_split, projection.n_best_chains, line, 'n_best_chains', 'number' );
                for chain=1:projection.n_best_chains
                    best_chain.n_parts = 0;
                    best_chain.scores = [];
                    line = fgetl(result_fid);
                    best_chain.n_parts = ReadResultField( str_split, best_chain.n_parts, line, 'n_parts', 'number' );                          
                    for part=1:best_chain.n_parts
                        line = fgetl(result_fid); 
                        best_chain.part_fits{part} = [];
                        best_chain.part_fits{part} = ReadResultField( str_split, best_chain.part_fits{part}, line, '', 'number_array', 0 );
                        line = fgetl(result_fid); 
                        best_chain.part_scores{part} = [];
                        best_chain.part_scores{part} = ReadResultField( str_split, best_chain.part_scores{part}, line, '', 'number_array', 0 );
                    end
                    line = fgetl(result_fid);
                    best_chain.scores  = ReadResultField( str_split, best_chain.scores, line, '', 'number_array', 0 );
                    projection.best_chains{chain} = best_chain;
                end
                if projection.n_best_chains == 0
                    line = fgetl(result_fid);
                    projection.size_error_message = ReadResultField( str_split, projection.size_error_message, line, 'size_error_message', 'number' );
                    line = fgetl(result_fid);
                    projection.error_message = ReadResultField( str_split, projection.error_message, line, 'error_message', 'whole_line' );                    
                end
                result.projections{curr_projection} = projection;
            end        
            results{ix_result} = result;
            [ results{ix_result}.clustered_projections ] = ClusterProjections( results{ix_result}.projections ) ;
            ix_result = ix_result + 1;
            fclose(result_fid);
        end   
    end        
end

