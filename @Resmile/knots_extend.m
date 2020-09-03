function knots = knots_extend(knots,degree)
    %Duplicate the first and the last knot (degree+1) times, for creating
    %B-splines. For example: `knots_extend([0 1 2 3],2)` results in the
    %following: `[0 0 0 1 2 3 3 3]` because for an 3-degree B-spline we
    %need to duplicate the first and the last element 2 times.
    knots=[repmat(knots(1),1,degree) knots repmat(knots(end),1,degree)];
end

