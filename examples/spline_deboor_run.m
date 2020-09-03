% Generate and display B-spline basis functions based on given knot sequence, using
% the spline_deboor function.
knotseq = [0 0 0 1 2 2 2]
x=linspace(-1,5,100);
clf
hold on
order = 2;
ysum = 0.*x;
for i=1:(length(knotseq)-3)
    y=arrayfun(@(a)spline_deboor(a, knotseq, i, order),x);
    plot(x,y)
    ysum = ysum + y;
end
plot(x,ysum)
legend('1','2','3','4','5','6')
