% Example for transforming state-space models to random basis, based on the following paper:
% Jan De Caigny; Rik Pintelon; Juan F. Camino; Jan Swevers, "Interpolated Modeling of LPV Systems", 
% IEEE Transactions on Control Systems Technology, Vol.22, No.6, November 2014.

ssmod=rss(3)
clf
bode(ssmod)
T=randn(size(ssmod.A,1))
transformed_ssmod = ss(T*ssmod.A*inv(T), T*ssmod.B, ssmod.C*inv(T), ssmod.D)
transformed_ssmod_ss2ss = ss2ss(ssmod,T) %this should be the same as the previous
hold on
bode(transformed_ssmod,'r--')
legend('original model','transformed model')
