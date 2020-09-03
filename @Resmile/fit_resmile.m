function fit_resmile(me)
    % Regularized, reweighted algorithm to fit splines to data.

    opt_init_common(me);

%  Here we are solving the optimization problem several times, each time improving the weighting matrices.  
%  In order to increase the efficiency of regularization, reweighting of the $\ell_{2,1}$ norm is applied as explained in \cite{boyd2008rwl}. Based on these ideas, we solve the optimization problem 

%  \begin{equation} \label{eq:fit_resmile}
%  \begin{array}{cc}\displaystyle
%  \underset{\Theta, s}{\operatorname{minimize}}~H_\Theta+\gamma \sum_{i=1}^{N_\Lambda - 2} \phi_{i,\hat \Theta} s_{i} \\[0.6cm]
%  \text { subject to } \zeta_{i,\Theta} \leq s_{i} ~~\vline~~ i=1, \ldots, N_\Lambda-g
%  \end{array}
%  \end{equation}
%  
%   in a loop (see \autoref{t:resmileoverview}) using a weighting term 
%  
%  \begin{equation}\label{eq:phihat}
%  \phi_{i,\hat \Theta}=\frac 1 {\zeta_{i,\Theta}+\epsilon},
%  \end{equation}
%  
%  which are based on $\hat \Theta$ coefficients from the previous iteration. The $\epsilon$ in \eqref{eq:phihat} is the parameter of the reweighting. $\frac 1 \epsilon$ is the maximum value that $\phi_{i,\hat \Theta}$ can take.

    iteration_count = 0;
    last_obj_value = 0; 
    psi_degree1 = coeff_tensor(me.basis_function.derivative(me.basis.degree));
    me.diff_psi_degree0 = diff(psi_degree1);
    me.w_tensor = ones(dims(me.diff_psi_degree0)); %that's the initial value
    me.knot_importances_by_iteration = [];
    me.obj_values_by_iteration = [];
    me.w_by_iteration = [];
    me.phi_by_iteration = [];
    me.phi = ones(dims(me.diff_psi_degree0,0),1);
    %clf %PARK check if removing that affects anything
    for iteration_count = 1:me.max_reweighting_iteration_count
        %if iteration_count == 3 || iteration_count == 100
        %    profile on
        %end
        %with diff(psi_degree1) we create the symbolic coeffs for the degree-0 spline:
        me.cones = me.w_tensor.*me.diff_psi_degree0;

        if iteration_count > 1, last_s_values = me.sol.value(me.s); end %this is the value of s from the last iteration
        me.s = me.opti.variable(dims(me.cones,0),1); %we create a new set of s variables, one for each cone

%  We weight $s$ with the following $\phi$ based on the the values of the $\theta$ from the last iteration (shown here as $\hat \theta$). This is as discussed in \cite{boyd2008rwl}. 
%  
%  For the first iteration however, we substitute $\phi$ with a vector of ones.  
%  We also do so in `OPTMODE_W` (in that case this part of the formula is switched off).

        if iteration_count > 1 % && optmode >= OPTMODE_PHI
            %This plotting part is for debugging. 
            %PARK could be moved to a separate function 
            if iteration_count >= me.phi_plotting_after_n_iterations 
                clf;
                parent_figure = gcf;
                parent_figure.WindowStyle='normal';
                htabgroup = uitabgroup(parent_figure);            
            end
            for i = 1:numel(me.s)
                w_values = me.w_tensor(1,:);
                importance_right_side = diff_psi_degree0_values(i,:);
                multiplied_values = w_values.*importance_right_side;
                phi_norm = norm(multiplied_values,'fro');
                me.phi(i) = 1./(phi_norm + me.epsilon); 
                if iteration_count >= me.phi_plotting_after_n_iterations
                    htab = uitab(htabgroup, 'Title', ['phi' num2str(i)]);
                    hax = axes('Parent', htab);
                    subplot(3,2,[1])
                    barvalues(w_values);
                    title("W"), xlabel("×")
                    subplot(3,2,[3])
                    barvalues(importance_right_side);
                    xlabel("‖")
                    subplot(3,2,[5])
                    barvalues(multiplied_values);
                    subplot(3,2,2)
                    barvalues([phi_norm me.phi(i)]);
                    xlabel("norm, me.phi")
                    subplot(3,2,[4 6])
                    image(imread(['images' filesep 'phi_calculation.png']));
                    set(gca, 'Visible', 'off');
                end

                %if phi_norm < min_reweighting_phi_norm
                    %me.phi(i) = 1;
                    %disp(['me.phi(' num2str(i) ') is not updated, to not grow too high. phi_norm = ' num2str(phi_norm)])
                %else 
                %end
                
            end
            if iteration_count >= me.phi_plotting_after_n_iterations
                disp('Press any key to continue...');
                pause;
            end
        else
            me.phi = ones(size(me.s)); 
        end
        me.phi_by_iteration(iteration_count,:) = me.phi;
        me.w_by_iteration(iteration_count,:,:) = squeeze(me.w_tensor(1,:,:)); %it should be the same regardless of the first index
        disp_w = squeeze(me.w_tensor(1,:,:)), disp_phi = me.phi' %print W and phi in every iteration

%  The objective is the following:
%  
        me.obj = norm(me.en)+me.gamma*sum(me.phi.*me.s);        
%  
%  We clear all the former constraint and reapply them with the modified weights.  
%  We also set the initial values for the solver for the next iteration, based on the previous iteration.  

        me.opti.subject_to %clear all
        if iteration_count > 1
            me.opti.set_initial(me.s, last_s_values)
            me.opti.set_initial(coeff_tensor(me.basis_function),Resmile.coeff2data(me.sol.value(coeff_tensor(me.basis_function)))) 
        end
        cone_formulas={};
        for i = 1:numel(me.s)
            me.conei = matrix(me.cones(i,:,:));
            me.conei = me.conei(:);
            me.opti.subject_to(norm(me.conei) <= me.s(i));
            cone_formulas{i} = norm(me.conei);
        end
        
        me.opti.minimize(me.obj)
        me.sol = me.opti.solve();

%  We can create an animation to show how the importances of the knots change from iteration to iteration. It will look like this:
%  
%  ![](images/fit_resmile_knot_importances.gif)
        
        if me.knot_importances_gif && iteration_count == 1, clf; end

        me.knot_importances = Resmile.get_knot_importances(Resmile.coeff2data(me.sol.value(me.w_tensor.*me.diff_psi_degree0)),'plot',me.knot_importances_gif)

        if me.knot_importances_gif
            title(['knot importances in iteration ' num2str(iteration_count) ', objective = ' num2str(me.sol.value(me.obj))])
            ylim([0 10^ceil(log10(max(me.knot_importances)))])
            if iteration_count == 1
                gif('resmile_knot_importances.gif','DelayTime',0.1,'frame',gcf); 
            else
                gif;
            end
        end
        me.knot_importances_by_iteration = [me.knot_importances_by_iteration me.knot_importances];
        me.obj_values_by_iteration = [me.obj_values_by_iteration me.sol.value(me.obj)];
        
        me_sol=me.sol; %This is a workaround for MATLAB not being able to evaluate @me.sol.value
        sol_value_norm_conei = cellfun(@me_sol.value, cone_formulas)'
        sol_value_s = me.sol.value(me.s)
        %TODO some comment here why do we print these
        imp_s_difference = me.knot_importances-sol_value_s
        cone_s_difference = sol_value_norm_conei-sol_value_s
        
        disp(['reweighting iteration ' num2str(iteration_count) ...
            ', objective = ' num2str(me.sol.value(me.obj)) ... 
            ', norm(en) = ' num2str(me.sol.value(norm(me.en))) ...
            ', sum(s) = ' num2str(me.sol.value(sum(me.s)))])
        psi_degree1_values = Resmile.coeff2data(me.sol.value(psi_degree1)); 
        diff_psi_degree0_values = Resmile.coeff2data(me.sol.value(me.diff_psi_degree0));

        obj_value = me.sol.value(me.obj);
        reweighting_improvement = last_obj_value-obj_value;
        % PARK this could be later fixed, though it still works fine if we just apply a fixed number of 5 iterations
        % if reweighting_improvement < me.reweighting_improvement_tol && reweighting_improvement > 0
        %     disp(['Stopping iterations because objective function failed to improve more than ' num2str(me.reweighting_improvement_tol) '.'])
        %     break
        % end
        last_obj_value = obj_value;

%% Spline remover
%PARK could be a separate function as well

        %if  iteration_count < 3
            %If there are any values close to zero, we'll end up with very large values, 
            %and the reweighting iterations will fail with NaNs
            if iteration_count == 1
                switch me.spline_remover_mode
                case Resmile.SR_OFF
                    me.spline_remover = ones(me.ss_size1,me.ss_size2)
                case Resmile.SR_MANUAL
                    me.spline_remover_constraint_d1 = me.spline_remover_user == 2
                    me.spline_remover_constraint_d2 = me.spline_remover_user == 2 | me.spline_remover_user == 1
                    me.spline_remover = double(me.spline_remover_user == 0)
                case Resmile.SR_AUTO
                    coeffs_d2 = Resmile.coeff2data(me.sol.value(coeff_tensor(me.basis_function.derivative(2))));
                    coeffs_d1 = Resmile.coeff2data(me.sol.value(coeff_tensor(me.basis_function.derivative(1))));
                    me.spline_remover_constraint_d2 = squeeze(var(coeffs_d2)) < me.spline_remover_var_threshold_d2 & squeeze(abs(mean(coeffs_d2))) < me.spline_remover_mean_threshold_d2
                    me.spline_remover_constraint_d1 = squeeze(var(coeffs_d1)) < me.spline_remover_var_threshold_d1 & squeeze(abs(mean(coeffs_d1))) < me.spline_remover_mean_threshold_d1 & me.spline_remover_constraint_d2    
                    me.spline_remover = 1.*~me.spline_remover_constraint_d2  
                end
            end
            if me.force_w_to_ones %previously serious bug discovered here, but now it should be fine
                me.w = me.spline_remover;
            else
                if me.w_calc_mode == Resmile.W_CALC_PSI1
                    w_denominator = squeeze(rms(psi_degree1_values))
                elseif me.w_calc_mode == Resmile.W_CALC_DPSI0
                    w_denominator = squeeze(rms(diff_psi_degree0_values))
                end
                %w_denominator(w_denominator<min_reweighting_w_denominator) = 1 
                %w_denominator
                
                me.w = me.spline_remover./w_denominator; %based on psi
                %If there are zeroes in the original values, we will end up with Inf-s in w. 
                %Most likely this would only happen to physical models.
                me.w(me.w==Inf)=1;
            end
            for i = 1:size(me.w_tensor,1)
               me.w_tensor(i,:,:) = me.w; %we need to apply this on all knots   
            end
            %if iteration_count == 3 || iteration_count == 100
            %    profile off
            %    profile viewer
            %    pause
            %end
        %end
    end

    if me.knot_importances_gif
        for i=1:10, gif; end %we add a few frames to the end of the gif
        %we try to optimize the gif file for smaller size using `gifsicle`. Fails with an error? Comment this out then:
        !gifsicle resmile_knot_importances.gif -O3 -o resmile_knot_importances_optimized.gif
    end 

    disp([mfilename ': The knot importances are as follows:'])
    me.knot_importances
