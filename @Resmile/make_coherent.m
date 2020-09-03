function make_coherent(me)
    % convert the input data to a coherent set of state-space models
    me.input_data.all_models = [me.input_data.training_models me.input_data.validation_models];
    training_model_indexes = 1:length(me.input_data.training_models);
    validation_model_indexes = length(me.input_data.training_models)+(1:length(me.input_data.validation_models));
    me.input_data.all_sched_params = [me.input_data.training_sched_params me.input_data.validation_sched_params];
    [me.input_data.all_sched_params, all_sched_params_indexes] = sort(me.input_data.all_sched_params);
    me.input_data.all_models = me.input_data.all_models(all_sched_params_indexes);
    me.input_data.all_models = Resmile.decaigny(me.input_data.all_models, me.apply_balreal);
    all_models_original_order(all_sched_params_indexes) = me.input_data.all_models;
    me.input_data.training_models = all_models_original_order(training_model_indexes);
    me.input_data.validation_models = all_models_original_order(validation_model_indexes);


