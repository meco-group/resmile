function result = cellarray_list_eval(ca,where)
    % Call `list_eval(where)` on a 2D cell array of `splines.Function`.
    for x=1:size(ca,1)
        for y=1:size(ca,2)
            result(:,x,y) = ca{x,y}.list_eval(where);
        end
    end
end
