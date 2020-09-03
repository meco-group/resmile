function rsm=resmile_test
    %No unit testing framework used so far, for now if this runs through without errors then we assume it's good.
    function dataset_has_every_item(x)
        dst=dbstack; disp(['dataset_has_every_item: we have come from line ' num2str(dst(2).line)])
        x
        x.training_sched_params;
        x.validation_sched_params;
        x.all_sched_params;
        x.display_sched_params;
        x.use_display_sched_params;
        x.training_models;
        x.validation_models;
        x.all_models;
        x.bode_frequencies;
    end
 
    Resmile
    Resmile.dataset_oc
    dataset_has_every_item(Resmile.dataset_msd)
    dataset_has_every_item(Resmile.dataset_random)
    opts = Resmile.dataset_random_default_opts
    opts.mode = Resmile.DSRAND_CLEAN
    dataset_has_every_item(Resmile.dataset_random(opts))
    opts.mode = Resmile.DSRAND_CLEANW
    dataset_has_every_item(Resmile.dataset_random(opts))
    opts.mode = Resmile.DSRAND_NOISYW
    dataset_has_every_item(Resmile.dataset_random(opts))
    opts.mode = Resmile.DSRAND_REMOVER_TEST
    dataset_has_every_item(Resmile.dataset_random(opts))
    rsm = Resmile;    
    rsm.dataset_load('dsrand_noisyw1');
    rsm.dataset_load('dsrand_noisyw2');
    rsm = Resmile(Resmile.dataset_oc);
    rsm.set_input(Resmile.dataset_oc);
    rsm.make_coherent
    %rsm.simplify  %should throw error
    %rsm.analyze   %should throw error
    rsm.fit_ls
    rsm.simplify
    rsm.analyze
    rsm.fit_regsimple
    rsm.simplify
    rsm.analyze
    rsm.fit_resmile
    rsm.analyze
    rsm.simplify
    rsm.analyze 
    if exist('resmile_knot_importances.gif', 'file')==2, delete('resmile_knot_importances.gif'); end %! rm -f
    rsm.knot_importances_gif = true;
    rsm.fit_resmile
    rsm.knot_importances_gif = false;
    rsm.convert_mosekdebug
    %rsm.analyze_random %TODO
end
