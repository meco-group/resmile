function input_data = load_grid(g)
    % Create input data struct from `GridMod` (type of LCToolbox).
    input_data.training_sched_params = g.params_{2};
    input_data.validation_sched_params = []; 
    input_data.all_sched_params = input_data.training_sched_params;
    input_data.validation_models={};
    for i=1:length(g.grid_)
        input_data.training_models{i}=ss(g.grid_{i}.A,g.grid_{i}.B,g.grid_{i}.C,g.grid_{i}.D,g.grid_{2}.Ts);
    end
    input_data.all_models=input_data.training_models;
    input_data.display_sched_params = input_data.training_sched_params;
    input_data.use_display_sched_params = false;
        
