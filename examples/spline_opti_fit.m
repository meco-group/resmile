% Fit a B-spline to a custom curve loaded from a PNG file using optispline.
% Display spline after fitting.

curve_y = png2curve("spline_deboor_input.png");
curve_y = curve_y/max(curve_y);
curve_x = linspace(0,1,length(curve_y));
degree = 2;
import splines.*;
opti = OptiSpline();
B = BSplineBasis([0 1],degree,10);
F = opti.Function(B)
e = F.list_eval(curve_x) - curve_y';
opti.minimize(e'*e)
opti.solver('ipopt')
sol = opti.solve()
spline_result = sol.value(F)
spline_result.coeff_tensor
spline_y = spline_result.list_eval(curve_x);
clf
hold on
plot(curve_x,curve_y)
plot(curve_x,spline_y)
legend('original data','spline')
