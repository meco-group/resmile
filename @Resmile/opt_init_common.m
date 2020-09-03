function opt_init_common(me)
    % Initialize common part of optimization problems for knot removal 

    make_basis(me)
    me.removed_knots = false; 
    me.w_tensor = []; %reinitialization: at this point we don't know what kind of opt. problem will be solved.

%  We will use Mosek+YALMIP because the problem to solve is an SOCP.  
    me.opti = OptiSplineYalmip();
    ops = sdpsettings('solver','mosek','savesolverinput',1,'savesolveroutput',1,'verbose',me.solver_verbose,'savedebug',1,'mosektaskfile','mosekdebug.tar.gz');

%  Those parameters below can decrease the difference between the actual knot importances and $s$. Joris Gillis suggested that `MSK_DPAR_INTPNT_CO_TOL_PFEAS` and `MSK_DPAR_INTPNT_CO_TOL_DFEAS` to `1e-12` improved accuracy while experimenting with some toy problems, so even if the documentation adivses against it, we should set those accordingly. ~~I set those to `eps` to decrease the constraint violations even more.~~ Setting those to `eps` drives the solver to never find a solution and give status `UNKNOWN`.
    ops.mosek.MSK_DPAR_INTPNT_CO_TOL_DFEAS = 1e-11;
    ops.mosek.MSK_DPAR_INTPNT_CO_TOL_PFEAS = 1e-11;
    me.opti.solver('yalmip',struct('yalmip_options',ops,'use_optimize',true));

%  The `basis_function` contains the basis definition and the coefficient matrix.  
%  The size of the coefficient matrix $\Theta$ is the same as of all $P$-s.
    me.basis_function = me.opti.Function(me.basis,size(Resmile.ss2p(me.input_data.training_models{1}))); 

%  ### Loading the data
%  
%  Create arrays of $P_j = \begin{bmatrix}A_j&B_j\\C_j&D_j\end{bmatrix}$ matrices, one for the training models, and one for all (training+validation) models.  
%  $j$ here is the index of the $j$-th scheduling parameter $\alpha_j$ to which $P$ corresponds to. Dimension 1 indexed with `i` in the code is the same.

    for i=1:length(me.input_data.training_sched_params)
        me.p_matrices_training(i,:,:) = Resmile.ss2p(me.input_data.training_models{i});
    end

    for i=1:length(me.input_data.all_sched_params)
        me.p_matrices_accurate(i,:,:) = Resmile.ss2p(me.input_data.all_models{i});
    end

    [me.ss_size1, me.ss_size2] = size(Resmile.ss2p(me.input_data.training_models{1}));

%  Common parts of the optimization formulas. 

    p_symbolic_bsplinebasis = me.basis_function.list_eval(me.input_data.training_sched_params);
    me.e = p_symbolic_bsplinebasis - me.p_matrices_training;
    me.en = matrix(me.e(:));
