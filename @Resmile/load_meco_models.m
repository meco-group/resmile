function [models, scheduling_params]=load_meco_models(models_info, path_prefix)
    % Internal function that is used to load overhead crane data from the `.mat` files procided in `models_info`, 
    % from the directory defined with `path_prefix` (should end with `/`).
    models={};
    scheduling_params=[];
    for i=1:size(models_info,2)
        loaded_model=load([path_prefix models_info{i}{1}]);
        models{i}=loaded_model.ssModh;
        scheduling_params=[scheduling_params models_info{i}{2}];
    end

