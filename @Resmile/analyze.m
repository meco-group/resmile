function analyze(me)
    % Calculate errors of spline fitting and prepare data for plotting

%  Now let's evaluate the results of our spline at both the training and the validation set of scheduling parameters!  
%  Let's also evaluate linear and cubic interpolation results at those points just to compare.  
%  Note that I replaced `cubic` with `pchip` because it means the same for `interp1` but MATLAB is always issuing a lot of warnings on the first one.

    if isempty(me.sol)
        error('Resmile:NoSolution','The optimization problem has not been solved, cannot analyze. Run fit_resmile, fit_regsimple or fit_ls first.')
    end
    %% Calculate different models
    me.spline_result = me.sol.value(me.basis_function);

    me.p_matrices_spline_interp = me.spline_result.list_eval(me.input_data.display_sched_params);
    me.p_matrices_spline_interp_dp = me.spline_result.list_eval(me.input_data.all_sched_params); %at data points only
    me.p_matrices_spline_interp_kp = me.spline_result.list_eval(me.knot_places);

    if me.removed_knots
        me.p_matrices_map_spline_interp = Resmile.cellarray_list_eval(me.map_spline_result,me.input_data.display_sched_params);
        me.p_matrices_map_spline_interp_dp = Resmile.cellarray_list_eval(me.map_spline_result,me.input_data.all_sched_params); %at data points only
        me.p_matrices_map_spline_interp_kp = Resmile.cellarray_list_eval(me.map_spline_result,me.map_knot_places); 
        %Let's calculate here some error between the two splines at `disp_sched_parameters`!
        disp("The error of the mapped spline after removing the knots of low importance,")
        disp("evaluated at disp_sched_parameters:")
        map_error_l2norm = norm(reshape(me.p_matrices_spline_interp-me.p_matrices_map_spline_interp, [prod(size(me.p_matrices_map_spline_interp)) 1]),2)
        me.p_matrices_final_result = me.p_matrices_map_spline_interp;
        me.p_matrices_final_result_dp = me.p_matrices_map_spline_interp_dp;
    else 
        me.p_matrices_final_result = me.p_matrices_spline_interp;
        me.p_matrices_final_result_dp = me.p_matrices_spline_interp_dp;
    end

    me.p_matrices_linear_interp = Resmile.dimexchange_interp1_3dmat(Resmile.interp1_3dmat(Resmile.dimexchange_interp1_3dmat(me.p_matrices_training,'forward'),me.input_data.display_sched_params,'linear',me.input_data.training_sched_params),'backward');
    me.p_matrices_cubic_interp = Resmile.dimexchange_interp1_3dmat(Resmile.interp1_3dmat(Resmile.dimexchange_interp1_3dmat(me.p_matrices_training,'forward'),me.input_data.display_sched_params,'pchip',me.input_data.training_sched_params),'backward');

%  Let's convert the state-space models to frequency domain using `bode`.  
%  We'll need it for both the error calculations and the graphs.

    [me.bode_sched_param_surf, me.bode_frequencies_surf, me.bode_amplitudes_spline_interp, me.bode_phases_spline_interp] = Resmile.bode_p_matrices(me.input_data.display_sched_params, me.input_data.bode_frequencies, me.p_matrices_final_result, me.input_data.training_models{1});
    [~, ~, me.bode_amplitudes_linear_interp, me.bode_phases_linear_interp] = Resmile.bode_p_matrices(me.input_data.display_sched_params, me.input_data.bode_frequencies, me.p_matrices_linear_interp, me.input_data.training_models{1});
    [~, ~, me.bode_amplitudes_cubic_interp, me.bode_phases_cubic_interp] = Resmile.bode_p_matrices(me.input_data.display_sched_params, me.input_data.bode_frequencies, me.p_matrices_cubic_interp, me.input_data.training_models{1});
    [~, ~, me.bode_amplitudes_accurate, me.bode_phases_accurate] = Resmile.bode_p_matrices(me.input_data.display_sched_params, me.input_data.bode_frequencies, me.p_matrices_accurate, me.input_data.training_models{1});

    if ~me.input_data.use_display_sched_params
        %We convert the results obtained using `bode` to complex numbers
        bode_complex_spline = Resmile.bode2complex(me.bode_amplitudes_spline_interp, me.bode_phases_spline_interp);
        bode_complex_linear = Resmile.bode2complex(me.bode_amplitudes_linear_interp, me.bode_phases_linear_interp);
        bode_complex_cubic = Resmile.bode2complex(me.bode_amplitudes_cubic_interp, me.bode_phases_cubic_interp);
        bode_complex_accurate = Resmile.bode2complex(me.bode_amplitudes_accurate, me.bode_phases_accurate);

        me.bode_complex_error_spline = abs(bode_complex_spline-bode_complex_accurate);
        me.bode_complex_error_linear = abs(bode_complex_linear-bode_complex_accurate);
        me.bode_complex_error_cubic = abs(bode_complex_cubic-bode_complex_accurate);
    end

%% Display errors

%  We also show the errors of the interpolation at all scheduling parameter values (both the training and the validation set). 

    if ~me.input_data.use_display_sched_params
        disp(['spline interpolation error ' num2str(sum(sum(me.bode_complex_error_spline)))]);
        disp(['linear interpolation error ' num2str(sum(sum(me.bode_complex_error_linear)))]);
        disp(['cubic interpolation error ' num2str(sum(sum(me.bode_complex_error_cubic)))]);
        %should check for all of them: isstable(ss_model_spline_interpolated)
    end

    %%
    format longEng
    disp(['The error term in the formula after fit_* step (norm(en)): ' num2str(me.sol.value(norm(me.en))) newline]);
    disp(['The total error of the P matrix at data points' newline '(scheduling parameter values for which we have measurements):'])
    %p_diff = me.p_matrices_accurate-me.p_matrices_final_result_dp; %This would also be a way to calculate
    %p_total_error_dp=squeeze(vecnorm(p_diff))
    %p_total_error_dp_sum = norm(p_diff(:))
    p_total_error_dp=squeeze(sum(abs(me.p_matrices_accurate-me.p_matrices_final_result_dp),1))'
    p_total_error_dp_sum = sum(sum(p_total_error_dp))
    %disp(['Now we divide p_total_error_dp by the RMS of the splines:'])
    %p_total_error_dp_normalized=p_total_error_dp./squeeze(rms(me.p_matrices_final_result_dp))
    disp(['The total error of the P matrix at all_sched_params' newline '(which might include sched. params in between data points if use_display_sched_params is true):'])
    p_total_error_disp=squeeze(sum(abs(me.p_matrices_linear_interp-me.p_matrices_final_result),1))'
    p_total_error_disp_sum = sum(sum(p_total_error_disp))
    disp(['This is expected to be low if we don''t overfit.' newline 'Note: error matrices are per P matrix element.'])

    me.p_total_error_dp = p_total_error_dp; %Otherwise MATLAB won't print the name of the variable
    me.p_total_error_dp_sum = p_total_error_dp_sum;
    me.p_total_error_disp = p_total_error_disp;
    me.p_total_error_disp_sum = p_total_error_disp_sum;

    %if remove_knots
    %    final_knot_importance_coeffs = sol.value(diff(coeff_tensor(basis_function.derivative(basis.degree))));
    %else
    %    final_knot_importance_coeffs = map_sol.value(diff(coeff_tensor(map_basis_function.derivative(map_basis.degree))));
    %end
    %disp(['This error is calculated from the norm of the coefficient matrix of 3rd derivative of the spline:'])
    %p_norm_error = norm(final_knot_importance_coeffs(:),'fro')

    %%

    disp(['This is the value of the error term at the end of the ' newline '1st optimization step (before removing knots):'])
    p_step1_error = me.sol.value(norm(me.en))

    if me.removed_knots %TODO test this part as well
        disp(['These are the values of the error terms at the end of the ' newline '2nd optimization step (after removing knots):'])
        for x = 1:size(me.map_sol,1)
            for y = 1:size(me.map_sol,2)
                p_step2_error(x,y) = me.map_sol{x,y}.value(me.map_obj{x,y});
            end
        end
        p_step2_error
        me.p_step1_error = p_step1_error;
        me.p_step2_error = p_step2_error;
    end
    format

%% Print summary
%  There used to be functionality to print a summary about the task carried out, but now that the code is structured differently, probably it does not make that much sense:

    %regularization_print_text = iif(gamma>0, ['γ = ' num2str(gamma)],  'regularization off');
    %knots_print_text = iif(knots_distribute_mode == KNOTS_ACCURATELY, '', 'not ');
    %optmode_text = {'non-regularized', 'cones (6.19)', 'cones + W (6.20)', 'cones + W + phi (6.24)'};
    %if last_input_selection_index == models.OLD_CRANE 
    %    model_print_text = iif(old_crane_use_balreal,'balreal is on','balreal is off'); 
    %else 
    %    model_print_text = '';
    %end
    %disp(['-----' newline 'Task summary:' newline 'optimization formula: ' optmode_text{optmode+1} ', knots are ' knots_print_text 'on the data points, ' regularization_print_text ', ' model_print_text])

