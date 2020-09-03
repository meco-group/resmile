function y=resmile_dataset_random_default_opts(mode_arg)
    % Return default options for random dataset generation. 
    if nargin == 0, mode_arg = Resmile.DSRAND_CLEAN; end
    y.random_spline_degree = 2; %Degree of random splines to be created.
    % Blank state-space model to determine sizes of matrices:
    y.random_spline_example_ss = ss(ones(2),ones(2,1),ones(1,2),[1]); %3x3 
    %y.random_spline_example_ss = ss(ones(2),ones(2),ones(1,2),[1 1]); %3x4
    y.random_spline_training_sched_params = 0:0.1:3; % Training scheduling parameters of random spline
    y.random_spline_display_sched_params = 0:0.1:3; % Display scheduling parameters of random spline
    y.random_spline_knots = [0 0 0 1 2 3 3 3]; % Knots of random spline
    y.noise_multiplier_const = 0.01;
    y.mode = mode_arg; %Mode of random spline, can be TODO
