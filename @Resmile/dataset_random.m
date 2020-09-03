function output=dataset_random(opts)
    % Generate random dataset based on `opts`. 
    % Can work in 4 modes (based on `opts.mode`):
    % - DSRAND_CLEAN: generate clean splines with given knots and random coefficients
    % - DSRAND_CLEANW: as the previous one, but make the range of the splines different (e.g. multiply one of them by 1e-2, the other by 1e+3)
    % - DSRAND_NOISYW: as the previous one, but also add another spline as noise which has a random number of knots (max. 20) and random coefficients.
    %       Scale this added random part by `opts.noise_multiplier_const`.
    % - DSRAND_REMOVER_TEST: as DSRAND_CLEANW, but make some of the splines a straight line (that should be auto-detected and removed by `spline_remover` 
    %       in `fit_resmile`)
    if nargin == 0; opts = Resmile.dataset_random_default_opts; end
    if ~strcmp(class(opts),'struct'), opts = Resmile.dataset_random_default_opts(opts); end
    [random_ss_size1, random_ss_size2] = size(Resmile.ss2p(opts.random_spline_example_ss));
    output.training_sched_params = opts.random_spline_training_sched_params;
    output.all_sched_params = output.training_sched_params;
    output.display_sched_params = opts.random_spline_display_sched_params;
    output.bode_frequencies = [logspace(log10(0.03),log10(100),100)]; 
    output.validation_sched_params = [];
    output.use_display_sched_params = true;
    random_spline_offset_weight = 0;

    for x=1:random_ss_size1
        for y=1:random_ss_size2
            random_spline_multipliers(x,y) = 1;
            random_spline_offset(x,y) = 0;
            if opts.mode == Resmile.DSRAND_CLEANW || opts.mode == Resmile.DSRAND_NOISYW || opts.mode == Resmile.DSRAND_REMOVER_TEST
                random_spline_multipliers(x,y)=10^(randi(7,1,1)-3);
                random_spline_offset(x,y) = random_spline_offset_weight*random_spline_multipliers(x,y)*(rand(1,1)-0.5)*2;
            end
            [~, clean_model_spline_values, clean_model_coeff_vector] = Resmile.opti_generate_random_spline(opts.random_spline_degree,opts.random_spline_knots,output.training_sched_params);
            clean_model_p_matrix(:,x,y) = random_spline_offset(x,y)+random_spline_multipliers(x,y)*clean_model_spline_values;
            output.clean_model_coeff_matrix(:,x,y) = random_spline_offset(x,y)+random_spline_multipliers(x,y)*clean_model_coeff_vector;
        end
    end
    
    if opts.mode == Resmile.DSRAND_REMOVER_TEST
        line_a = randn*random_spline_multipliers(2,3);
        line_b = randn*random_spline_multipliers(2,3);
        line_c = randn*random_spline_multipliers(3,3);
        line_noise_proportion = 0.00000001;
        clean_model_p_matrix(:,2,3) = line_a.*output.training_sched_params'+line_b+line_noise_proportion*randn(length(output.training_sched_params),1);
        clean_model_p_matrix(:,3,3) = 0.*output.training_sched_params'+line_c+line_noise_proportion*randn(length(output.training_sched_params),1);
    end

    if opts.mode == Resmile.DSRAND_NOISYW
        for x=1:random_ss_size1
            for y=1:random_ss_size2
                noise_knots_places = sort(min(output.training_sched_params)+(max(output.training_sched_params)-min(output.training_sched_params))*rand(1+randi(20,1,1),1))';
                noise_knots = Resmile.knots_extend(noise_knots_places, opts.random_spline_degree);
                noise_multiplier = random_spline_multipliers(x,y)*opts.noise_multiplier_const; %_max*(rand(1,1)*2-1);
                [~, noise_spline_values, ~] = Resmile.opti_generate_random_spline(opts.random_spline_degree,noise_knots,output.training_sched_params);
                clean_model_p_matrix(:,x,y) = clean_model_p_matrix(:,x,y) + noise_multiplier*noise_spline_values;
            end
        end
    end
    
    for i=1:size(clean_model_p_matrix,1)
        output.training_models{i} = Resmile.p2ss(squeeze(clean_model_p_matrix(i,:,:)),opts.random_spline_example_ss);
        output.all_models{i} = output.training_models{i};
    end
    output.validation_models = {};

