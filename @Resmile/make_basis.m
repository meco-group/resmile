function make_basis(me)
    % Distribute knots and create BSplineBasis object.

%  `me.knots_distribute_mode` allows to set the way knots and scheduling parameters for which we have data relate to each other.

%  ### Create the B-spline bases
%  
%  We create the B-spline basis with the knots defined in `training_sched_params`.  
%  
%  The size of the coefficient matrix is dependent on the number of knots and also the spline degree. 
%  
%  - For a 0-degree spline with 14 knots (to fit 10 data points) we our coefficient matrix has a length of 9.
%  - For an 1-degree spline with 14 knots (to fit 10 data points) we our coefficient matrix has a length of 10.
%  - For a 2-degree spline with 14 knots (to fit 10 data points) we our coefficient matrix has a length of 11.
%  
%  However, if we try to fit 1 spline basis to 1 data point each, we'll see that this will not always work, for example for the 2-degree spline we will have 11 degrees of freedom. This will result in overfitting like this:
%  
%  ![image.png](images/make_basis_1.png)
%  
%  To overcome this problem, we don't fit 1 spline basis to 1 data point each. For a 2-degree spline, we will have 13 knots (at 9 places) and fit those to 10 data points. An example for that:
%  
%  ![image.png](images/make_basis_2.png)

    import splines.*
    knots_num = length(me.input_data.training_sched_params)-me.bspline_degree+1;
    if me.knots_distribute_mode == Resmile.KNOTS_EVENLY
        me.knot_places = linspace(min(me.input_data.training_sched_params),max(me.input_data.training_sched_params),knots_num); %distribute knots evenly
    elseif me.knots_distribute_mode == Resmile.KNOTS_IN_MIDDLE
        me.knot_places = me.input_data.training_sched_params(1:end-1)+diff(me.input_data.training_sched_params)*0.5; %distribute knots in the middle between data points
        me.knot_places(1) = me.input_data.training_sched_params(1);
        me.knot_places(end) = me.input_data.training_sched_params(end);
    elseif me.knots_distribute_mode == Resmile.KNOTS_FAIR_A
        me.knot_places = me.input_data.training_sched_params(1:end-1)+diff(me.input_data.training_sched_params).*linspace(0,1,length(me.input_data.training_sched_params)-1); %distribute knots in the middle between data points

%  By using the mode below, we can get back to the situation where we were having too many degrees of freedom. Note that if regularization is enabled ($\gamma \gt 0$), it might also remove knots by converging to 0 with their coefficients, so we should set $\gamma = 0$ if we want to see this effect.

    elseif me.knots_distribute_mode == Resmile.KNOTS_ACCURATELY
        me.knot_places = me.input_data.training_sched_params; %we can make some overfitting by choosing this, and setting gamma=0!
    end

%  Because the spline degree is 2, we need to duplicate the first and the last knot (`Resmile.knots_extend`).

    me.knots = Resmile.knots_extend(me.knot_places,me.bspline_degree);
    disp([ mfilename ': knots placed at:'])
    me.knots
    me.basis = BSplineBasis(me.knots,me.bspline_degree);

