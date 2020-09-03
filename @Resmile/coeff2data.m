function y=coeff2data(x)
    % Converts splines.Coefficient to numeric values, needed by Optispline
    % v0.1. Doesn't touch the input if it is already numeric.
    if strcmp(class(x),'splines.Coefficient')
        y=x.data;
    else
        y=x;
    end