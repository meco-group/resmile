% Least-squares fit a B-spline to a custom curve loaded from a PNG file using 
% MATLAB operator \ and basis functions generated using `spline_deboor`. 
% Display spline after fitting.
curve=png2curve("spline_deboor_input.png");  %get curve (index of first nonzero element in a black and white image)
clf
hold on
knotseq = [0 0 0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.7 0.8 1 1 1]; %we add a discontinuity at 0.7
x=linspace(0,1,length(curve));
plot(x,curve)
order = 2;
basenum=length(knotseq)-3; %number of bases
bases=zeros(length(curve),basenum);
for i=1:basenum
    bases(:,i)=arrayfun(@(a)spline_deboor(a, knotseq, i, order),x);
end
solution=bases\curve' %we LS fit
for i=1:basenum
    plot(x,bases(:,i)*solution(i)) 
end
plot(x,bases*solution) %we add up 
