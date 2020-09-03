function res = spline_deboor(x, t, i, k)
% Evaluate the de Boor recursive formula (as in Dora Turk's thesis [1]) to generate B-spline
% basis functions.
% x: current value we try to evaluate
% t: knots
% i: which interval
% k: current order
% References:
% [1] Dora Turk, "Regularized Identification of Linear Parameter-Varying Systems: Methods and 
%     Mechatronic Applications", KU Leuven, 2018

    if nargin == 0, spline_deboor_run, return, end %F5 keyboard shortcut to try example
    if k<=0
       if ((t(i)<=x)&&(x<t(i+1))), res = 1; else, res = 0; end
    else
        t1 = t(i+k)-t(i);
        t2 = t(i+k+1)-t(i+1);
        s1 = spline_deboor(x,t,i,k-1);
        s2 = spline_deboor(x,t,i+1,k-1);
        if(t1 == 0 && s1 == 0), s1_per_t1 = 0; else s1_per_t1 = s1/t1; end
        if(t2 == 0 && s2 == 0), s2_per_t2 = 0; else s2_per_t2 = s2/t2; end
        res = (x-t(i))*s1_per_t1+(t(i+k+1)-x)*s2_per_t2;
    end
