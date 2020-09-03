function make_3dplot
    % Apply settings that are common for all 3D plots created in the toolbox.
    h = gca;
    set(h,'yscale','log');
    xlabel('scheduling parameter')
    ylabel('frequency')
    view([125 45]) %rotate view on 3D display
