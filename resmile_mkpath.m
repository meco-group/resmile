function resmile_mkpath(x)
    % Script to set the path correctly for using the toolbox.
    % Add Resmile to MATLAB path:
    %   mkpath 
    % Remove Resmile from MATLAB path:
    %   mkpath remove
    if nargin==1 && strcmp(x,'remove')
        rmpath('.','examples','lib','datasets','tests')    
    else
        addpath('.','examples','lib','datasets','tests')    
    end
end

