function [basis, spline_values, coeffs] = opti_generate_random_spline(degree, knots, eval_here, varargin)
    % Generate random spline for `dataset_random` function, with given `degree`, `knots`.
    % Parameters: 
    % - `basis`: `BSplineBasis` object
    % - `knots`: knot sequence
    % - `eval_here`: spline function argument values (sched. parameter values in the context of LPV) where the function should be evaluated
    % - `plot` (optional): `on`/`off` can choose whether to create a plot 
    % 
    % This is based on code for the following presentation:
    % D. Turk, L. Jacobs, T. Singh, W. Decré and J. Swevers, "Identification of Linear Parameter-Varying Systems Using B-splines," 2019 18th European Control Conference (E%CC), Naples, Italy, 2019, pp. 3316-3321, doi: 10.23919/ECC.2019.8795917.

    import splines.*
    
    parser = inputParser; 
    addOptional(parser,'plot','off');
    parse(parser,varargin{:});
    plot_on=strcmp(parser.Results.plot,'on');
    
    if nargin==0
        knots=[0 0 0 1 2 2 2]; 
        degree = 2; 
        eval_here = linspace(0,max(knots),200); 
    end
    
    basis = BSplineBasis(knots,degree);
    tensor_basis = TensorBasis(basis,'x');
    num_coeffs = length(knots)-degree*2+1;
    coeffs = rand(num_coeffs, 1)';
    coeffs_object = Coefficient(coeffs);
    spline_function = Function(tensor_basis,coeffs_object);
    spline_values = spline_function.list_eval(eval_here);
    
    if plot_on
        clf
        subplot(211); plot(eval_here,spline_values);
        title('spline generated with cpp\_splines')    
        subplot(212); 
        % basis functions for x
        for i=1:size(coeffs,2)
            eval_here = linspace(0,max(knots),200);
            c = zeros(1,size(coeffs,2)); c(i) = 1;
            Fb = Function(tensor_basis,Coefficient(c)); 
            y = Fb.list_eval(eval_here);
            subplot(212); plot(eval_here,y); hold on;
        end
        title('basis functions NOT scaled up with coefficients')
    end
