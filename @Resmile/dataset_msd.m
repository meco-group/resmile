function output=dataset_msd 
    % Generate state-space models of a mass-spring-damper system with different mass values.
    % This is a white-box model based on physics we know in advance. In this model, the input is the force, the output
    % is the displacement, and we’ve chosen the weight of the mass as the scheduling parameter.

%  We generate models of mass-spring-damper system:
%  ![](images/resmile_dataset_msd.gif)

%  These allow us to set the $\alpha$ scheduling parameter values for which we want to train and validate our algorithm against.
    output.training_sched_params = 0.1:0.1:1;
    output.validation_sched_params = setdiff(0.1:0.01:1,output.training_sched_params);
    output.use_display_sched_params = false;
%  More initialization. We create `output.all_sched_params` that contains both validation and training scheduling parameters.  
%  We figure out the frequencies at which we'll calculate the `bode` diagram.
    output.all_sched_params=unique(sort([output.validation_sched_params output.training_sched_params]));
    output.display_sched_params = output.all_sched_params; %This is compulsory in case output.use_display_sched_params = false
    output.bode_frequencies=logspace(-1,2,64)';
%  We create the mass-spring-damper models using `mkss_msd`:
    mkss_fun = @(x){Resmile.mkss_msd(x)};
    output.training_models = cellfun(mkss_fun,num2cell(output.training_sched_params));
    output.all_models = cellfun(mkss_fun,num2cell(output.all_sched_params));
    output.validation_models = {};
