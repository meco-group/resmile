function plot_chooser_gui(me)
    % Shows a GUI to choose from different kinds of plots.

    selection_index = listdlg('PromptString',{'Select a graph to be shown:'}, ...
        'ListSize', [640 480],'InitialValue',3,'SelectionMode','single','ListString', ...
        {'Interpolated FRFs', ...
        'Errors of FRFs', ...
        'Show splines, coeffs, knots, values over iterations' });

    switch selection_index
        case 1
            me.plot(Resmile.PL_TABS_FRF)
        case 2
            me.plot(Resmile.PL_TABS_FRFERR)
        case 3
            me.plot(Resmile.PL_TABS_SPLINES)
    end
