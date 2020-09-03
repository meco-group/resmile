function plot(me, type)
    % Create various plots based on `type`. Can plot splines, knot importances, FRFs, etc.
    set(0,'defaultAxesFontSize',16);
    titlefun = @(a) title(['var = ' num2str(var(a)) newline 'rms = ' num2str(rms(a)) newline]);
    switch type
        case Resmile.PL_FRF_BSPLINE_AMPLITUDE
            surf(me.bode_sched_param_surf, me.bode_frequencies_surf, mag2db(me.bode_amplitudes_spline_interp));
            title('B-spline interpolated FRFs')
            zlabel('amplitude (dB)')
            Resmile.make_3dplot;
        case Resmile.PL_FRF_BSPLINE_PHASE
            surf(me.bode_sched_param_surf, me.bode_frequencies_surf, me.bode_phases_spline_interp);
            title('B-spline interpolated FRFs')
            zlabel('phase (deg)')
            Resmile.make_3dplot;
        case Resmile.PL_FRF_LI_AMPLITUDE %TODO test these
            surf(me.bode_sched_param_surf, me.bode_frequencies_surf, mag2db(me.bode_amplitudes_linear_interp));
            title('Linear interpolated FRFs')
            zlabel('amplitude (dB)')
            Resmile.make_3dplot;
        case Resmile.PL_FRF_LI_PHASE
            surf(me.bode_sched_param_surf, me.bode_frequencies_surf, me.bode_phases_linear_interp);
            title('Linear interpolated FRFs')
            zlabel('phase (deg)')
            Resmile.make_3dplot;
        case Resmile.PL_TABS_FRF
            hfig1 = gcf;
            hfig1.WindowStyle='normal';
            htabgroup = uitabgroup(hfig1);
            htab1 = uitab(htabgroup, 'Title', 'B-spline amplitude');
            hax1 = axes('Parent', htab1);
            plot(me, Resmile.PL_FRF_BSPLINE_AMPLITUDE);
            htab2 = uitab(htabgroup, 'Title', 'B-spline phase');
            hax2 = axes('Parent', htab2);
            plot(me, Resmile.PL_FRF_BSPLINE_PHASE);
        case Resmile.PL_FRFERR_BSPLINE_LI_AMPLITUDE
            assert(isequal(me.input_data.display_sched_params, me.input_data.all_sched_params), "this plot is only supported for models where there is no separate me.display_sched_params")
            hold on;
            surf(me.bode_sched_param_surf, me.bode_frequencies_surf, mag2db(abs(me.bode_amplitudes_spline_interp-me.bode_amplitudes_accurate)),'FaceColor','g','FaceAlpha',0.5);
            surf(me.bode_sched_param_surf, me.bode_frequencies_surf, mag2db(abs(me.bode_amplitudes_linear_interp-me.bode_amplitudes_accurate)),'FaceColor','b','FaceAlpha',0.5);
            title('Amplitude error of interpolated models compared to accurate model')
            legend('B-spline interpolated model','linear interpolated model')
            Resmile.make_3dplot;
            hold off;
        case Resmile.PL_FRFERR_BSPLINE_LI_PHASE
            assert(isequal(me.input_data.display_sched_params, me.input_data.all_sched_params), "this plot is only supported for models where there is no separate me.display_sched_params")
            hold on;
            surf(me.bode_sched_param_surf, me.bode_frequencies_surf, mag2db(abs(me.bode_phases_spline_interp-me.bode_phases_accurate)),'FaceColor','g','FaceAlpha',0.5);
            surf(me.bode_sched_param_surf, me.bode_frequencies_surf, mag2db(abs(me.bode_phases_linear_interp-me.bode_phases_accurate)),'FaceColor','b','FaceAlpha',0.5);
            title('Phase error of interpolated models compared to accurate model')
            legend('B-spline interpolated model','linear interpolated model')
            Resmile.make_3dplot;
            hold off;
        case Resmile.PL_FRFERR_BSPLINE_CI_AMPLITUDE
            assert(isequal(me.input_data.display_sched_params, me.input_data.all_sched_params), "this plot is only supported for models where there is no separate me.display_sched_params")
            hold on;
            surf(me.bode_sched_param_surf, me.bode_frequencies_surf, mag2db(abs(me.bode_amplitudes_spline_interp-me.bode_amplitudes_accurate)),'FaceColor','g','FaceAlpha',0.5);
            surf(me.bode_sched_param_surf, me.bode_frequencies_surf, mag2db(abs(me.bode_amplitudes_cubic_interp-me.bode_amplitudes_accurate)),'FaceColor','b','FaceAlpha',0.5);
            title('Amplitude error of interpolated models compared to accurate model')
            legend('B-spline interpolated model','cubic interpolated model')
            Resmile.make_3dplot;
            hold off;
        case Resmile.PL_FRFERR_BSPLINE_CI_PHASE
            assert(isequal(me.input_data.display_sched_params, me.input_data.all_sched_params), "this plot is only supported for models where there is no separate me.display_sched_params")
            hold on;
            surf(me.bode_sched_param_surf, me.bode_frequencies_surf, mag2db(abs(me.bode_phases_spline_interp-me.bode_phases_accurate)),'FaceColor','g','FaceAlpha',0.5);
            surf(me.bode_sched_param_surf, me.bode_frequencies_surf, mag2db(abs(me.bode_phases_cubic_interp-me.bode_phases_accurate)),'FaceColor','b','FaceAlpha',0.5);
            title('Phase error of interpolated models compared to accurate model')
            legend('B-spline interpolated model','cubic interpolated model')
            Resmile.make_3dplot; 
            hold off;
        case Resmile.PL_FRFERR_BSPLINE_LI_CI_AMPLITUDE
            assert(isequal(me.input_data.display_sched_params, me.input_data.all_sched_params), "this plot is only supported for models where there is no separate me.display_sched_params")
            hold on;
            surf(me.bode_sched_param_surf, me.bode_frequencies_surf, mag2db(me.bode_complex_error_spline),'FaceColor','g','FaceAlpha',0.5);
            surf(me.bode_sched_param_surf, me.bode_frequencies_surf, mag2db(me.bode_complex_error_linear),'FaceColor','b','FaceAlpha',0.5);
            surf(me.bode_sched_param_surf, me.bode_frequencies_surf, mag2db(me.bode_complex_error_cubic),'FaceColor','r','FaceAlpha',0.5);
            title('Error of interpolated models compared to accurate model')
            legend('B-spline interpolated model','linear interpolated model','cubic interpolated model')
            Resmile.make_3dplot;
            hold off;
        case Resmile.PL_TABS_FRFERR
            hfig1 = gcf;
            hfig1.WindowStyle='normal';
            htabgroup = uitabgroup(hfig1);

            htab1 = uitab(htabgroup, 'Title', 'Amplitude B-spline & LI vs. accurate');
            hax1 = axes('Parent', htab1);
            plot(me, Resmile.PL_FRFERR_BSPLINE_LI_AMPLITUDE)
            
            htab2 = uitab(htabgroup, 'Title', 'Phase B-spline & LI vs. accurate');
            hax2 = axes('Parent', htab2);
            plot(me, Resmile.PL_FRFERR_BSPLINE_LI_PHASE)
            
            htab3 = uitab(htabgroup, 'Title', 'Amplitude B-spline & CI vs. accurate');
            hax3 = axes('Parent', htab3);
            plot(me, Resmile.PL_FRFERR_BSPLINE_CI_AMPLITUDE)
            
            htab4 = uitab(htabgroup, 'Title', 'Phase B-spline & CI vs. accurate');
            hax4 = axes('Parent', htab4);
            plot(me, Resmile.PL_FRFERR_BSPLINE_CI_PHASE)

            htab5 = uitab(htabgroup, 'Title', 'Amplitude of all models');
            hax5 = axes('Parent', htab5);
            hold on;
            plot(me, Resmile.PL_FRFERR_BSPLINE_LI_CI_AMPLITUDE)
        case Resmile.PL_SPLINES_OLD
            for x=1:me.ss_size1 
                for y=1:me.ss_size2
                    subplot(me.ss_size1,me.ss_size2,(x-1)*me.ss_size2+y)
                    hold on
                    plot(me.input_data.all_sched_params,squeeze(me.p_matrices_accurate(:,x,y)),'b');
                    plot(me.input_data.display_sched_params,squeeze(me.p_matrices_spline_interp(:,x,y)),'k');
                    [~,scheduling_param_data_indexes]=intersect(me.input_data.all_sched_params,me.input_data.training_sched_params,'stable');
                    scatter(me.input_data.training_sched_params,me.p_matrices_accurate(scheduling_param_data_indexes,x,y),32,'r','filled');
                    scatter(me.knot_places,me.p_matrices_spline_interp_kp(:,x,y),32,'g','filled');
                    title(['spline (' num2str(x) ',' num2str(y) ')']);
                    if me.removed_knots
                        plot(me.input_data.display_sched_params,squeeze(me.p_matrices_map_spline_interp(:,x,y)),'r--');
                        scatter(me.map_knot_places,me.p_matrices_map_spline_interp_kp(:,x,y),32,'filled','MarkerFaceColor',[0 0.6 0]);
                    end
                    if x==1 && y==1
                        legend('accurate state','interpolated state','fitted data','knots','simplified interp. state','knots not removed','Location','Best')
                    end
                end
            end
        case Resmile.PL_SPLINES
            format short
            for x=1:me.ss_size1 
                for y=1:me.ss_size2
                    subplot(me.ss_size1,me.ss_size2,(x-1)*me.ss_size2+y)
                    hold on
                    [~,scheduling_param_data_indexes]=intersect(me.input_data.all_sched_params,me.input_data.training_sched_params,'stable');
                    scatter(me.input_data.training_sched_params,me.p_matrices_accurate(scheduling_param_data_indexes,x,y),64,'r','filled');
                    plot(me.input_data.display_sched_params,squeeze(me.p_matrices_spline_interp(:,x,y)),'b','LineWidth',2);
                    scatter(me.knot_places,me.p_matrices_spline_interp_kp(:,x,y),32,'filled','b');
                    title(['spline (' num2str(x) ',' num2str(y) ')']);
                    xlabel('\alpha sched. param. value');
                    ylabel(['state-space matrix' newline 'element value']);
                    if me.removed_knots
                        plot(me.input_data.display_sched_params,squeeze(me.p_matrices_map_spline_interp(:,x,y)),'--','LineWidth',2,'Color',[0 0.8 0]);
                        scatter(me.map_knot_places,me.p_matrices_map_spline_interp_kp(:,x,y),32,'filled','MarkerFaceColor',[0 0.8 0]);
                    end
                    if x==1 && y==1
                        legend('input data','spline','knots','simplified spline','knots (simplified spline)','Location','Best')
                    end
                end
            end
            format
        case Resmile.PL_KNOTS
            if ~isempty(me.w_tensor) % if optmode >= OPTMODE_W %TODO test if works properly
                me.get_knot_importances(me.sol.value(me.w_tensor.*me.diff_psi_degree0),'plot',true,'knot_keep',me.knot_keep_not_extended) 
                disp('Calculating get_knot_importances based on w_tensor * diff_psi_degree0')
                %this will not work if we have no w, so:
            else
                me.get_knot_importances(diff(coeff_tensor(me.spline_result.derivative(me.basis.degree))),'plot',true,'knot_keep',me.knot_keep_not_extended) 
                disp('Calculating get_knot_importances based on ||psi_i+1 - psi_i||F')
                %this does not have the w
            end
            %me.get_knot_importances(spline_result.coeff_tensor) %the theta itself makes no sense to plot
        case Resmile.PL_COEFFS
            for x=1:me.ss_size1 
                for y=1:me.ss_size2
                    subplot(me.ss_size1,me.ss_size2,(x-1)*me.ss_size2+y)
                    plot_this = me.sol.value(coeff_tensor(me.basis_function));
                    bar_color = '';
                    if exist('spline_remover'), bar_color = iif(me.spline_remover(x,y)~=0,'','r'); end
                    bar(plot_this(:,x,y),bar_color)
                    titlefun(plot_this(:,x,y));
                end
            end
        case Resmile.PL_DCOEFFS1
            for x=1:me.ss_size1 
                for y=1:me.ss_size2
                    subplot(me.ss_size1,me.ss_size2,(x-1)*me.ss_size2+y)
                    plot_this = me.sol.value(coeff_tensor(me.basis_function.derivative(1)));
                    bar(plot_this(:,x,y))
                    titlefun(plot_this(:,x,y));
                end
            end
        case Resmile.PL_DCOEFFS2
            for x=1:me.ss_size1 
                for y=1:me.ss_size2
                    subplot(me.ss_size1,me.ss_size2,(x-1)*me.ss_size2+y)
                    plot_this = me.sol.value(coeff_tensor(me.basis_function.derivative(2)));
                    bar(plot_this(:,x,y))
                    titlefun(plot_this(:,x,y));
                end
            end
        case Resmile.PL_DCOEFFS3
            for x=1:me.ss_size1 
                for y=1:me.ss_size2
                    subplot(me.ss_size1,me.ss_size2,(x-1)*me.ss_size2+y)
                    plot_this = me.sol.value(diff(coeff_tensor(me.basis_function.derivative(2))));
                    bar(plot_this(:,x,y))
                    titlefun(plot_this(:,x,y));
                end
            end
        case Resmile.PL_REW_KNOTS
            for y=1:size(me.knot_importances_by_iteration,1)
                subplot(size(me.knot_importances_by_iteration,1),1,y)
                semilogy(me.knot_importances_by_iteration(y,:),'b');
                ylabel('value')
                if y==1, title('Knot importances during reweighting'); end
            end
            xlabel('#iteration')
        case Resmile.PL_REW_OBJ
            plot(1:length(me.obj_values_by_iteration), mag2db(me.obj_values_by_iteration))
            title('Objective value during reweighting [dB]')
            xlabel('#iteration'), ylabel(['objective' newline 'value'])
        case Resmile.PL_REW_W
            for x=1:me.ss_size1 
                for y=1:me.ss_size2
                    subplot(me.ss_size1,me.ss_size2,(x-1)*me.ss_size2+y)
                    semilogy(squeeze(me.w_by_iteration(:,x,y)),'b');
                    title(['w (' num2str(x) ',' num2str(y) ')']);
                    xlabel('#iteration'), ylabel(['w'])
                end
            end
        case Resmile.PL_REW_PHI
            for y=1:numel(me.s)
                subplot(numel(me.s),1,y)
                plot(me.phi_by_iteration(:,y),'b');
                ylabel(['\phi'])
            end
            xlabel('#iteration')
        case Resmile.PL_TABS_SPLINES
            hfig1 = gcf;
            hfig1.WindowStyle='normal';
            htabgroup = uitabgroup(hfig1);
            htab1 = uitab(htabgroup, 'Title', 'Splines');
            hax1 = axes('Parent', htab1);
            plot(me, Resmile.PL_SPLINES)

            htab15 = uitab(htabgroup, 'Title', 'Knots');
            hax15 = axes('Parent', htab15);        
            plot(me, Resmile.PL_KNOTS)

            htab2 = uitab(htabgroup, 'Title', 'Coeffs');
            hax2 = axes('Parent', htab2);
            plot(me, Resmile.PL_COEFFS)

            htab3 = uitab(htabgroup, 'Title', 'dCoeffs 1');
            hax3 = axes('Parent', htab3);
            plot(me, Resmile.PL_DCOEFFS1)

            htab4 = uitab(htabgroup, 'Title', 'dCoeffs 2');
            hax4 = axes('Parent', htab4);
            plot(me, Resmile.PL_DCOEFFS2)

            htab5 = uitab(htabgroup, 'Title', 'dCoeffs 3');
            hax5 = axes('Parent', htab5);
            plot(me, Resmile.PL_DCOEFFS3)

%  Here we plot the norms of the derivative coefficient matrices to see if regularization worked:  
%
%  $$\left\lVert \Psi_{(i+1)} - \Psi_{(i)} \right\lVert_F$$
%
%  $$i=1 \dots l$$

            if ~isempty(me.w_tensor) % if optmode >= OPTMODE_W
                % These tabs are only shown if reweighting is applied!
                htab7 = uitab(htabgroup, 'Title', 'Rew. knots');
                hax7 = axes('Parent', htab7);
                plot(me, Resmile.PL_REW_KNOTS)

                htab6 = uitab(htabgroup, 'Title', 'Rew. objective');
                hax6 = axes('Parent', htab6);
                plot(me, Resmile.PL_REW_OBJ)

                htab8 = uitab(htabgroup, 'Title', 'Rew. W');
                hax8 = axes('Parent', htab8);
                plot(me, Resmile.PL_REW_W)

                htab9 = uitab(htabgroup, 'Title', 'Rew. Phi');
                hax9 = axes('Parent', htab9);
                plot(me, Resmile.PL_REW_PHI)
            end
    end
