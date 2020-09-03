function simplify(me)
    % Create new spline with less knots, based on result of `fit_resmile` or `fit_regsimple`.
    if isempty(me.knot_importances)
        error('Resmile:NoKnotImportances','No knot_importances yet, cannot simplify. Run fit_resmile or fit_regsimple first.')
    end
%  Over here we first:
%  1. remove the knots below threshold
%  2. project the results to a new spline with less knots by separately solving the following LS problem:
%  
%  \begin{equation}\label{eq:simplify}
%  \underset{\Theta}{\operatorname{minimize}} \sum_{j=1}^{N_\kappa}\left(\mathscr{P}_{x,y,\Theta, g, \lambda}(\kappa_j) -\mx P_{x,y,j}\right)^2.
%  \end{equation}
%  
%  for each $x,y$ indexed element in our $\mx P$ matrix. We add the constraint 
%  
%  \begin{equation}\label{eq:linfunconstr}
%  {\operatorname{subject ~to}}~~  \mathscr{P}_{x,y,\Theta,g,\lambda}^{(g)}(\alpha) =0 ~~ \vline~~ \forall~ \alpha.
%  \end{equation}
%  
%  on splines for which \eqref{eq:linfuncdetect} holds. We add both \eqref{eq:linfunconstr} and 
%  
%  \begin{equation}\label{eq:constfuncconstr}
%  {\operatorname{subject ~to}}~~ \mathscr{P}_{x,y,\Theta,g,\lambda}^{(g-1)}(\alpha) = 0~~ \vline~~ \forall~ \alpha.
%  \end{equation}
%  
%  on splines for which both \eqref{eq:linfuncdetect} and \eqref{eq:constfuncdetect} holds.
%  
%  The "all scheduling parameters" here can either mean `training_sched_params` or a larger set, something like `disp_sched_params`. TODO We should be able to choose which one to use here. We could also blend `training_sched_params` with a finer set, e.g. also all the sched params in between and in between... 
%  
%  Let's first figure out which knots to remove:

    import splines.*
    me.knot_keep_not_extended = me.knot_importances>me.knot_removal_threshold; %1 for each knot to keep, 0 to discard
    assert(me.bspline_degree == 2, "removing knots in only supported for bspline_degree == 2")
    if me.bspline_degree == 2, knot_keep = [1;me.knot_keep_not_extended;1], end %we extend it with 1-s for the first and the last knots
    assert(length(knot_keep)==length(me.knot_places))
    if me.bspline_degree == 2
        knot_keep_indexes = knot_keep.*(1:length(knot_keep))';
        knot_keep_indexes = knot_keep_indexes(knot_keep_indexes~=0);
        me.map_knot_places = me.knot_places(knot_keep_indexes);
    end
    me.map_knots = Resmile.knots_extend(me.map_knot_places,me.bspline_degree);
    me.map_ops = sdpsettings('solver','mosek','savesolverinput',1,'savesolveroutput',1,'verbose',me.solver_verbose,'savedebug',1,'mosektaskfile','mosekmapdebug.tar.gz');
    me.map_ops.mosek.MSK_DPAR_INTPNT_CO_TOL_DFEAS = 1e-11;
    me.map_ops.mosek.MSK_DPAR_INTPNT_CO_TOL_PFEAS = 1e-11;

%  Now let's do that mapping:

    %'m
    for x=1:me.ss_size1
        for y=1:me.ss_size2
            disp(['Creating simplified spline: solving problem {' num2str(x) ',' num2str(y) '}']);
            me.map_opti{x,y} = OptiSplineYalmip(); 
            me.map_basis{x,y} = BSplineBasis(me.map_knots,me.bspline_degree);
            me.map_basis_function{x,y} = me.map_opti{x,y}.Function(me.map_basis{x,y});   
            %the following will be symbolic because the me.map_basis_function has not been solved yet:
            pelement_symbolic_map{x,y} = me.map_basis_function{x,y}.list_eval(me.input_data.training_sched_params);
            %the following will be numeric because the spline_result has already been solved:
            pelement_numeric_training = me.p_matrices_training(:,x,y);
            me.map_e = pelement_symbolic_map{x,y} - pelement_numeric_training;
            me.map_obj{x,y} = me.map_e'*me.map_e;
            %We rather create another instance of opti & the solver so that it doesn't overwrite our existing objects
            %which will hopefully increase debuggability. 
            me.map_opti{x,y}.solver('yalmip',struct('yalmip_options',me.map_ops,'use_optimize',true));
            if ~isempty(me.spline_remover_constraint_d1) %TODO we wanted to skip this part if optmode <= OPTMODE_W, but I need to check if it is a good condition
                if me.spline_remover_constraint_d1(x,y) 
                    %me.map_opti{x,y}.subject_to( me.map_basis_function{x,y}.derivative(1) == 0 ) %TODO: is it the same as making the coeff_tensor if it 0?
                    me.map_ct = coeff_tensor(me.map_basis_function{x,y}.derivative(1));
                    me.map_ct = matrix(me.map_ct(:));
                    me.map_opti{x,y}.subject_to( me.map_ct == 0 )
                end
                if me.spline_remover_constraint_d2(x,y) 
                    %me.map_opti{x,y}.subject_to( me.map_basis_function{x,y}.derivative(2) == 0 )
                    me.map_ct = coeff_tensor(me.map_basis_function{x,y}.derivative(2));
                    me.map_ct = matrix(me.map_ct(:));
                    me.map_opti{x,y}.subject_to( me.map_ct == 0 )
                end
            else
                warning("Skipping adding constraints at 2nd step, they are only supported for OPTMODE_PHI.") %TODO
            end
            me.map_opti{x,y}.minimize(me.map_obj{x,y})
            me.map_sol{x,y} = me.map_opti{x,y}.solve();
            me.map_spline_result{x,y} = me.map_sol{x,y}.value(me.map_basis_function{x,y});
        end
    end
    disp([num2str(length(knot_keep)-sum(knot_keep)) ' were removed out of ' num2str(length(knot_keep))]);
    disp('Original knot sequence (knots):');
    me.knots
    disp('New knot sequence (map_knots):')
    me.map_knots
    me.removed_knots = true;
