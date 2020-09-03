function barvalues(varargin)
    % Plotting function compatible with `bar`, just also prints the numerical values on top of the bars.
    % Based on information in this thread: https://www.mathworks.com/matlabcentral/answers/40629-bar-plot-value-on-top
    bar(varargin{:});
    if length(varargin)>=2
        values=varargin{2};
        xaxis=varargin{1};
    else
        values=varargin{1};
        xaxis=1:length(values);
    end
    yaxis=values;
    yaxis(0>yaxis)=0;
    text(xaxis,yaxis,arrayfun(@(x)string(sprintf('%.2g',x)),values(:)),'vert','bottom','horiz','center'); 
    box off
    set(gca,'xtick',[])
