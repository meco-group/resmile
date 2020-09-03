function [sched_param_surf, frequencies_surf, amplitudes_surf, phases_surf]=bode_p_matrices(sched_params, frequencies, p_matrices, example_ss_model)
    %Calculate bode surface plot data points from sets of models defined
    %with their `p_matrices`, at given `frequencies` and `sched_params`
    %scheduling parameters. The `p2ss` conversion will be carried out using
    %the matrix sizes in `example_ss_model`.
    %The results can be directly plotted using `surf`.
    %For an example, see `state_space_simple_spline_interp_3dplot`.
    [sched_param_surf, frequencies_surf] = meshgrid(sched_params,frequencies);
    amplitudes_surf = [];
    phases_surf = [];
    for i=1:length(p_matrices)
        [amplitudes, phases, ~] = bode(Resmile.p2ss(squeeze(p_matrices(i,:,:)),example_ss_model), frequencies); 
        amplitudes_surf = [amplitudes_surf squeeze(amplitudes)];
        phases_surf = [phases_surf squeeze(phases)];
    end
end
