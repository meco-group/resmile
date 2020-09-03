function output=dataset_chooser_gui
    % Shows a GUI to choose from different built-in datasets for ReSMILE.
    % Returns the dataset. 
    input_selection_index = listdlg('PromptString',{'Select input data to be used:'}, ...
        'ListSize', [500 200], 'SelectionMode','single','ListString', ... 
        {'Overhead crane', 'Mass-spring-damper','Random splines: clean','Random splines: random scale, clean','Random splines: random scale, noisy','Random splines: spline_remover test','dsrand_noisyw1','dsrand_noisyw2'});
    %  Models to choose from while using `Resmile.dataset_gui`:
    OLD_CRANE = 1;
    MSD = 2;
    CLEAN = 3;
    CLEANW = 4;
    NOISYW = 5;
    REMOVER_TEST = 6;
    C_DSRAND_NOISYW1 = 7;
    C_DSRAND_NOISYW2 = 8;
    random_opts = Resmile.dataset_random_default_opts;
    switch input_selection_index
        case OLD_CRANE
            output = Resmile.dataset_oc;
        case MSD
            output = Resmile.dataset_msd;
        case CLEAN
            random_opts.mode = Resmile.DSRAND_CLEAN;
            output = Resmile.dataset_random(random_opts);
        case CLEANW
            random_opts.mode = Resmile.DSRAND_CLEANW;
            output = Resmile.dataset_random(random_opts);
        case NOISYW
            random_opts.mode = Resmile.DSRAND_NOISYW;
            output = Resmile.dataset_random(random_opts);
        case REMOVER_TEST
            random_opts.mode = Resmile.DSRAND_REMOVER_TEST;
            output = Resmile.dataset_random(random_opts);
        case C_DSRAND_NOISYW1
            output = load('dsrand_noisyw1')
        case C_DSRAND_NOISYW2
            output = load('dsrand_noisyw2')
    end
