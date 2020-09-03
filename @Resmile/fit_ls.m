function fit_ls(me)
    % Fit splines to data using simple LS.

%  $\mathscr{P}(\Theta,\alpha_j)$ is the interpolated spline at the given traing $\alpha_j$ scheduling parameter values. In the code this is `basis_function.list_eval(training_sched_params)`.
%  
%  $P_j$ is the set of training models `p_matrices_training`.

    opt_init_common(me);
    me.obj = norm(me.en);
    me.opti.minimize(me.obj)
    me.sol = me.opti.solve();
    me.knot_importances = ones(length(me.knot_places)-2,1) %TODO is the size here correct?
    disp([mfilename ': no knots can be removed after a simple LS fit, because knot importances are not calculated.']) 
