

function [ best_scores, best_categ_scores, best_ptools, best_ptool_maps, SQs, P ] = SeedProjection( ideal_ptool, P, tool_mass, task_name, task_function, task_function_params, n_seeds, verbose, plot_fig )  
    %% default is not verbose
    if ~exist('verbose','var')
        verbose = 0;
    end 
    %% default is not plotting
    if ~exist('plot_fig','var')
        plot_fig = 0;
    end 
    %% get the hyper params
    [ ~, n_seeds_hyper, weights_ranked_voting ] = ProjectionHyperParams();
    if ~exist('n_seeds','var') || n_seeds < 1
        n_seeds = n_seeds_hyper;
    end
    %% get SQs from planting seeds and fitting constrained by the ideal ptool scale
    [ SQs_proj, fit_scores_proj ] = GetSQsFromPToolProjection( ideal_ptool, P, n_seeds, verbose );
    if verbose 
        disp([char(9) 'Extracting p-tools from the fitted SQs...']);
    end 
    [ ptools_proj, ptools_map_proj, ptools_errors_proj] = ExtractPToolsAltSQs(SQs_proj, tool_mass, fit_scores_proj);  
    %% avaliate GP
    if verbose 
        disp([char(9) 'Evaluating task function on #' num2str(size(ptools_proj,1)) ' p-tools...']);
    end
    task_scores = feval(task_function, task_function_params, ptools_proj);
    voting_matrix = [ptools_errors_proj' task_scores]; 
    beg_weight = 0;
    step_weight = 0.01;
    mid_weight = 1;
    end_weight = mid_weight/step_weight;
    weights = [beg_weight:step_weight:(mid_weight-step_weight) mid_weight:mid_weight:end_weight];
    n_weights = size(weights,2);
    if verbose 
        disp([char(9) 'Calculating rank voting for ' num2str(n_weights) ' different weight values...']);
    end    
    voting_matrix_normalised = NormaliseData(voting_matrix);
    best_ixs = zeros(1,n_weights);
    parfor i=1:n_weights
        [~,best_ixs(i)] = min(GetRankVector( voting_matrix_normalised, 0.001, [1 weights(i)], {'ascend', 'descend'} ));
    end    
    % get the best ptool to return
    best_ptools = ptools_proj(best_ixs,:);
    best_ptool_maps = ptools_map_proj(best_ixs,:);
    best_fit_scores = voting_matrix(best_ixs,1);
    best_scores = voting_matrix(best_ixs,2);
    best_categ_scores = TaskCategorisation(best_scores,task_name);
    [best_score,best_weight_ix] = max(best_scores);
    best_fit_score = best_fit_scores(best_weight_ix);
    if verbose 
        disp([char(9) 'Best p-tool found (task score; fit score)' char(9) num2str(best_score) char(9) num2str(best_fit_score)]);   
    end
    % plot the N best ptools  
    if plot_fig
        n_best_ptools = 3;
        for i=1:n_best_ptools
            [SQs, transf_lists] = rotateSQs(SQs,1,2,task_name);
            P = Apply3DTransfPCL(P,transf_lists);
            PlotPCLS(P,10000,1);
            PlotSQs({SQs{usage_ixs(best_options(i),1)} SQs{usage_ixs(best_options(i),2)}},1000);
            view([0 0]);
        end
    end
end