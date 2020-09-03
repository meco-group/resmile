function fit_regsimple(me)
    % Fit splines to data using regularization but not reweighting. 

%  ### Simple regularized, without reweighting 
%  
%  Now we want to minimize the following (this will be the `obj` objective):
%  
%  \begin{equation} \label{eq:fit_regsimple}
%  \begin{array}{cc}\displaystyle
%  \underset{\Theta, s}{\operatorname{minimize}}~H_\Theta +\gamma \sum_{i=1}^{N_\Lambda - 2} s_{i} \\[0.5cm]
%  \text { subject to }~ \zeta_{i,\Theta} \leq s_{i} ~~\vline~~ i=1, \ldots, N_\Lambda - 2.
%  \end{array}
%  \end{equation}
%  
%  This also includes the slack variable $s$ and the regularization parameter $\gamma$, so we need to initialize them. 
%  
%  $s$ is an array of `opti` variables, the vector length equals the number of `cones` (see later at the constraints), which depends on the number of knots and the spline degree.
%  
%  For $\gamma$, for the MSD system it will work for sure between $0.001 \ldots 0.0001$.  
%  In case of a too high value, the fitting will be worse (should be checked on the diagram showing the individual splines). 

    opt_init_common(me);
    me.cones = diff(coeff_tensor(me.basis_function.derivative(me.basis.degree))); %see later
    me.s = me.opti.variable(dims(me.cones,0),1);
    me.obj = norm(me.en)+me.gamma*sum(me.s);

%  OK, let's add all the constraints!
%  
%  Note that at this point we have to add $l$ number of contraints.  
%  But will not have as many elements as knots because of the derivations, so we cannot go `1:num_knots`. We'd better go till the number of `cones`: `1:dims(cones,0)`.

    for i = 1:dims(me.cones,0)
        me.conei = matrix(me.cones(i,:,:));
        me.conei = me.conei(:);
        me.opti.subject_to(norm(me.conei) <= me.s(i));
    end

%  The call to `matrix` is needed because OptiSpline's `BSplineBasis` is creating a wrapper around a CasADi symbolic expression, and we use `matrix` to remove the wrapper (and first adjust the size stored in the metadata with `(:)` so that `matrix` will be able to work with it).
%  
%  Let's tell Opti $\rightarrow$ CasADi $\rightarrow$ YALMIP $\rightarrow$ Mosek to solve this problem!

    me.opti.minimize(me.obj)
    me.sol = me.opti.solve();

%  We also need to calculate the knot importances. This part was about debugging how the formulas are parsed through YALMIP, and we don't need it anymore:

    %obj_value_yalmip = yalmip_evaluate_casadi_formula(opti,obj,sol);
    %format long
    %disp(['opt(casadi) = ' num2str(sol.value(obj)) ', opt(yalmip) = ' num2str(obj_value_yalmip{1})])
    %knot_importances_yalmip = [];
    % %s_yalmip = [];    
    %for i = 1:dims(cones,0)
    %    conei = matrix(cones(i,:,:));
    %    conei = conei(:);
    %    constraint_lhs = yalmip_evaluate_casadi_formula(opti,norm(conei),sol);  
    %    %constraint_rhs = yalmip_evaluate_casadi_formula(opti,s(i),sol);
    %    knot_importances_yalmip = [knot_importances_yalmip;constraint_lhs{1}];
    %    %s_yalmip = [s_yalmip;constraint_rhs];
    %end
    %sol_value_s=sol.value(s)
    %knot_importances_yalmip
    %cone_s_difference_yalmip = knot_importances_yalmip-sol_value_s

%  This is the actual part to calculate knot importances:

    me.knot_importances = [];
    cones_value = me.sol.value(me.cones);
    for i=1:dims(me.cones,0)
        me.knot_importances = [me.knot_importances;norm(squeeze(cones_value(i,:,:)),'fro')];
    end
    sol_value_s = me.sol.value(me.s);

    disp([mfilename ': The cone_s_difference should always be negative (all numbers),' newline 'or should be within the violation range reported by the solver.' newline 'To our experience this does not hold with Mosek 9 (might be a bug),' newline 'thus we are recommend using Mosek 8.'])
    me.cone_s_difference = me.knot_importances-sol_value_s;
    me.cone_s_difference
    %format long
    %knot_importances_yalmip_diff = knot_importances - knot_importances_yalmip
    %format
    disp([mfilename ': The knot importances are as follows:'])
    me.knot_importances
