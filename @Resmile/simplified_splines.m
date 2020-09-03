function sm = simplified_splines(me)
    % Return `splines.Function` of the splines resulting from `simplify`.
    assert(me.removed_knots, "can only run this after running Resmile.simplify");
    for x = 1:me.ss_size1
        smrow = [me.map_spline_result{x,1}];
        if me.ss_size2 >= 2
            for y = 2:me.ss_size2 %cannot concatenate with []
                smrow = [smrow me.map_spline_result{x,y}];
            end
        end
        if x == 1 %cannot concatenate with []
            sm = smrow;
        else
            sm = [sm; smrow];
        end
    end
end

