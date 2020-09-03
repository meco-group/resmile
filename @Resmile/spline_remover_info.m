function spline_remover_info(me)
    disp(['In the R matrix below:' newline '1: spline taken into consideration' newline ...
        '0: spline not taken into consideration' newline 'in the knot importance calculation in fit_resmile.'])
    me.spline_remover
    disp(['Constraints on g-th derivative in the simplify step (g=degree):'])
    me.spline_remover_constraint_d2
    disp(['Constraints on (g-1)-th derivative in the simplify step (g=degree):'])
    me.spline_remover_constraint_d1

