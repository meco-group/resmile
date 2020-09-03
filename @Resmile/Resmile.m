classdef Resmile < handle
    % A happy class to create simplified LPV models.
    methods (Access = public)
        function obj = Resmile(input_data)
            if nargin>=1
                obj.set_input(input_data)
            end
        end
        set_input(me,what)
        make_basis(me)
        opt_init_common(me)
        fit_regsimple(me)
        fit_ls(me)
        analyze(me)
        analyze_random(me)
        sm = simplified_splines(me)
        sm = simplified_ssmod(me, scheduling_parameter)
        dataset_load(me, mat_file)
        spline_remover_info(me)
    end
    methods (Access = private)
    end
    methods (Static)
        y = coeff2data(x)
        result = cellarray_list_eval(ca,where)
        input_data = load_grid(g)
        convert_mosekdebug
        make_3dplot
        [models, scheduling_params]=load_meco_models(models_info, path_prefix)
        [sched_param_surf, frequencies_surf, amplitudes_surf, phases_surf]=bode_p_matrices(sched_params, frequencies, p_matrices, example_ss_model)
        m = bode2complex(amplitudes, phases)
        knots = knots_extend(knots,degree)
        res = interp1_3dmat(m,interp1_xq,interp1_method,interp1_x)
        y = dimexchange_interp1_3dmat(x,direction)
        dataset = dataset_msd
        dataset = dataset_oc
        dataset = dataset_random(opts)
        opts = dataset_random_default_opts(mode_arg)
        y = mkss_msd(x)
        output_models = decaigny(input_models, gramian_enabled)
        [basis, spline_values, coeffs] = opti_generate_random_spline(degree, knots, eval_here, varargin)
        output = dataset_chooser_gui
        yssmod = p2ss(p,example_ssmod)
        p = ss2p(ssmod)
        knot_norms = get_knot_importances(coeff_tensor, varargin) 
    end
    properties (Constant)
%  ### General info on the ReSMILE
%  Interpolate state-space models, using the regularized, reweighted SMILE technique with 2-degree B-spline basis functions \cite{turk2018phd}.
% 
%  ----
%  A note on `x` and `y`: in these scripts they correspond to first and second coordinate.  
%  They do not correspond to horizontal and vertical directions inside the $P$ matrix, actually they're always the opposite, e.g. like this:
%  
%  ![](images/coordinates_xy.png)
%  
%  The $P$ matrix on the figure contains all the matrices of the state space model. (The source for the formula is \cite{turk2018phd}.)
%  
%  We have accurate data for the SS model at the blue rectangles. Each of these also correspond to a value of the scheduling parameter $\alpha$ (here the weight of the mass).
%  
%  What we want to do, is **to get a value for the SS model in between** the blue rectangles (where we have accurate data). So we fit B-splines on those data points, **one spline per matrix element** in the $P$ matrix.
%  
%  The figure shows a $2 \times 2$ sized $P$ matrix with 4 splines altogether, but in the code we use a $3 \times 3$ one with 9 splines.
%
%  We also want to remove as many knots as possible from the splines to make the resulting model feasible for LPV control design.
%  ### Constants 
%  `knots_distribute_mode` allows to set the way knots and scheduling parameters for which we have data relate to each other.
%  
%  - `KNOTS_ACCURATELY` will point 1 knot per data point, which results in too much degrees of freedom for a 2-degree spline. This might result in overfitting if regularization is switched off by setting `gamma = 0`. 
        KNOTS_ACCURATELY = 0; 
%  - `KNOTS_EVENLY` will place only as many knots as degree of freedom needed. For a 2-degree spline, this results in $N_{\textrm{data points}}-1$ knots, but these are evenly distributed between the minimum and maximum scheduling parameter. *This is a sensible default.*
%  ![](images/knots_evenly.png)
        KNOTS_EVENLY = 1; 
%  - `KNOTS_IN_MIDDLE` will place only as many knots as degree of freedom needed. It is not however advised to place knots evenly spaced, as the part of the spline where we typically need more knots is the one where we have more data points. In this case we put the knots just at the middle points between data points. However, we need to force the first and last knot to be on the corresponding data points.
%  ![](images/knots_in_middle.png)
        KNOTS_IN_MIDDLE = 2; 
%  - `KNOTS_FAIR_A` will place only as many knots as degree of freedom needed. It is similar to `KNOTS_IN_MIDDLE`, but it is not putting the knots right in the middle, but tries to more fairly pull them toward one of the data points. 
%  ![](images/knots_fair_a.png)
        KNOTS_FAIR_A = 3;
%  ----
%  Optimization problem to solve was previously defined with `optmode`. Now it is possible to choose between different formulas by calling the right function (`fit_*`)
        OPTMODE_NOREG = 0;
        OPTMODE_CONES = 1;
        OPTMODE_W = 2;
%  This was to add a weighting $W$ that acounts for the difference between the ranges of the parameters inside the $P$ matrix. For example, those are very different ranges:
%  ![](images/optmode_w_justify.png)
%  However, we ended up that this $W$ is not a good concept, so this mode should not be used (was useful for some time for internal debugging).
        OPTMODE_PHI = 3;
%  This adds reweighting described in \cite{boyd2008rwl}.

%  The following parameter switches on/off the creation of the final spline with the knots of low importance removed:
        % remove_knots = true; %TODO this will be in a separate function thus it will not be needed

%  The user can specify if he wants to force some splines to be considered straight lines and removed from the knot importance calculation. 
%  
%  - In `SR_OFF` mode no splines will be removed, which means that all of them will be taken into consideration while calculating the knot importances.
%  - In `SR_AUTO` mode the program determines which splines are to be taken as straight lines, based on the first and second derivatives of the spline after the first iteration and `spline_remover_threshold`.
%  - In `SR_MANUAL` mode `spline_remover_user` is used, which should be the same size as the $P$ matrix, and its items will tell which kind of splines we expect there:
%  ![](images/spline_remover.png)
        SR_OFF = 0; 
        SR_AUTO = 1; 
        SR_MANUAL = 2;
%  Calculate $W$ based on different formulas:
%  
%  - `W_CALC_PSI1`: 
%  
%  $$w_{jk}=\left(\sqrt{{1 \over l+1 } \left(\psi_{(1)jk}^2 + \psi_{(2)jk}^2  + \ldots + \psi_{(l+1)jk}\right)}\right)^{-1}$$ (source: [1])
%  
%  - `W_CALC_DPSI0`: 
%  
%  $$w_{jk}=\left(\sqrt{{1 \over l+1 } (\psi_{(2)jk}-\psi_{(1)jk})^2 + (\psi_{(3)jk}-\psi_{(2)jk})^2  + \ldots + (\psi_{(l+1)jk}-\psi_{(l)jk})^2 }\right)^{-1}$$
        W_CALC_PSI1 = 0;
        W_CALC_DPSI0 = 1;
        DSRAND_CLEAN = 3;
        DSRAND_CLEANW = 4;
        DSRAND_NOISYW = 5;
        DSRAND_REMOVER_TEST = 6;

        PL_TABS_FRF = 10;
        PL_FRF_BSPLINE_AMPLITUDE = 11;
        PL_FRF_BSPLINE_PHASE = 12;
        PL_FRF_LI_AMPLITUDE = 13;
        PL_FRF_LI_PHASE = 14;

        PL_TABS_FRFERR = 20;
        PL_FRFERR_BSPLINE_LI_AMPLITUDE = 21;
        PL_FRFERR_BSPLINE_LI_PHASE = 22;
        PL_FRFERR_BSPLINE_CI_AMPLITUDE = 23;
        PL_FRFERR_BSPLINE_CI_PHASE = 24;
        PL_FRFERR_BSPLINE_LI_CI_AMPLITUDE = 25;

        PL_TABS_SPLINES = 30;
        PL_SPLINES_OLD = 311;
        PL_SPLINES = 301;
        PL_KNOTS = 302;
        PL_COEFFS = 303;
        PL_DCOEFFS1 = 304;
        PL_DCOEFFS2 = 305;
        PL_DCOEFFS3 = 306;
        PL_REW_KNOTS = 307;
        PL_REW_OBJ = 308;
        PL_REW_W = 309;
        PL_REW_PHI = 310;
   end
   properties(SetAccess = public)
%  ## User-definiable parameters
%  Apply `balreal` function while running `make_coherent`. 
        apply_balreal = true;
%  `knots_distribute_mode` allows to set the way knots and scheduling parameters for which we have data relate to each other.
        knots_distribute_mode = Resmile.KNOTS_ACCURATELY;
%  If the importance of a knot is below this value, we will remove it:
        knot_removal_threshold = 1e-5;
%  Optimization problem to solve is defined with `optmode`:
        optmode = Resmile.OPTMODE_PHI;
        spline_remover_mode = Resmile.SR_AUTO;
        spline_remover_threshold = 1e-5;
        spline_remover_user = [0 0 0;1 2 0;0 0 0];
        spline_remover_var_threshold_d2 = 1e-5;
        spline_remover_mean_threshold_d2 = 1e-5;
        spline_remover_var_threshold_d1 = 1e-5;
        spline_remover_mean_threshold_d1 = 1e-5;
%  The regularization parameter $\gamma$ can be set here.  
%  *$\gamma = 0.01$ is a sensible default value* for both the crane and the MSD system.  
%  If set to 0, the regularization will be switched off (the regularization term will not be taken into consideration).  
        gamma = 0.01;
%  #### Parameters for reweighting only
%  $\epsilon$ for reweighting $\phi$ (in `OPTMODE_PHI` only): 
        epsilon = 0.01;
%  TODO If the objective function doesn't decrease more than this value in a new iteration, then stop reweighting: (We remove this from the code)
	%y.reweighting_improvement_tol = 0.00001;
%  The maximum number of reweighting iterations:
        max_reweighting_iteration_count = 5;
%  Switch on or off verbose solver output:
        solver_verbose = true;
%  Generate an animated GIF from how the knot importances change over time:
        knot_importances_gif = false;
%  The following one is a minimum value for the denominator of the formula, during $W$ calculation.
%  
%  ...if it is too small, then we'll get almost infinite elements in $W$. We just substitute these items in $W$ with 1.
        min_reweighting_w_denominator = 1e-5;
%  The following one is a minimum value for the Frobenius norm ($R$ times knot importance) part of the formula, during $\phi$ calculation.
%  
%  ...if it is too small, then we'll get almost infinite elements in $\Phi$, in this case we leave these items intact.
        min_reweighting_phi_norm = 1e-4;
%  Plot values that influence $\Phi$.
%  - Set to `inf` to switch plotting off completely.
%  - Set to 0 to plot in all iterations.
%  - Set to iteration count to plot starting from that iteration.
%  You will need to press a key in MATLAB command line to proceed to the next iteration.
        phi_plotting_after_n_iterations = inf;
%  You can turn the effect of $W$ off by setting it to constant ones, which only makes sense in `OPTMODE_PHI`:
        force_w_to_ones = true;
%  Choose formula for calculating $W$:
        w_calc_mode = Resmile.W_CALC_DPSI0;
        bspline_degree = 2;
%  ## For internal use (can still be accessed from outside to facilitate debugging)
        input_data
        knot_places
        knots
        basis
        basis_function
        opti
        p_matrices_training
        p_matrices_accurate
        ss_size1
        ss_size2
        e
        en
        obj
        sol
        cones
        conei
        s
        knot_importances
        cone_s_difference
        diff_psi_degree0
        w_tensor
        knot_importances_by_iteration
        obj_values_by_iteration
        w_by_iteration
        phi_by_iteration
        phi
        spline_remover_constraint_d2
        spline_remover_constraint_d1
        spline_remover
        w
        spline_result
        removed_knots = false
        p_matrices_spline_interp
        p_matrices_spline_interp_dp
        p_matrices_spline_interp_kp
        p_matrices_final_result
        p_matrices_final_result_dp
        p_matrices_linear_interp
        p_matrices_cubic_interp
        bode_sched_param_surf
        bode_frequencies_surf
        bode_amplitudes_spline_interp
        bode_phases_spline_interp
        bode_amplitudes_linear_interp
        bode_phases_linear_interp
        bode_amplitudes_cubic_interp
        bode_phases_cubic_interp
        bode_amplitudes_accurate
        bode_phases_accurate
        p_total_error_dp
        p_total_error_dp_sum
        p_total_error_disp
        p_total_error_disp_sum
        p_step1_error
        p_step2_error
        knot_keep_not_extended = nan
        map_knot_places
        map_knots
        map_ops
        map_opti
        map_basis
        map_basis_function
        map_e
        map_obj
        map_ct
        map_sol
        map_spline_result
        p_matrices_map_spline_interp
        p_matrices_map_spline_interp_dp
        p_matrices_map_spline_interp_kp
        bode_complex_error_spline
        bode_complex_error_linear
        bode_complex_error_cubic
   end
end
