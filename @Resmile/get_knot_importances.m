function knot_norms = get_knot_importances(coeff_tensor, varargin)
    % Calculate knot importances based on a 3-dimensional tensor of spline coefficients `coeff_tensor`.
    % Optional parameters:
    % - `plot`: true/false. Allows to switch plotting of knot importances on and off.
    % - `knot_keep`: a vector of boolean values on which knots to keep. 
    %       (Knots to be kept will be drawn with blue color. Knots removed will be drawn with red color.)
    params = inputParser;
    addParameter(params,'plot',false);
    addParameter(params,'knot_keep',nan);
    parse(params,varargin{:});
    knot_norms = [];
    for i = 1:size(coeff_tensor,1)
        M = squeeze(coeff_tensor(i,:,:));
        knot_norms = [knot_norms; norm(M,'fro')];
    end
    if params.Results.plot
        if ~isnan(params.Results.knot_keep)
            hold on
            x = (1:length(knot_norms))';
            x_keep = x.*double(params.Results.knot_keep);
            x_keep = x_keep(x_keep~=0);
            x_notkeep = x.*double(~params.Results.knot_keep);
            x_notkeep = x_notkeep(x_notkeep~=0);
            stem(x_keep, knot_norms(x_keep),'b','LineWidth',2)
            stem(x_notkeep, knot_norms(x_notkeep),'r','LineWidth',2)
            legend('knots above threshold (remain)','knots below threshold (removed)','Location','Best')
            hold off
        else
            stem(knot_norms,'LineWidth',2)
        end
        
        title('knot importances')
        ylabel('norm value'), xlabel('knot #')
    end
end
