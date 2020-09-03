function y=mkss_msd(m,k,b)
    %mkss_msd(m,k,b): 
    %Creates a continuous state space model of mass-spring-damper system.
    %m: mass
    %k: damping
    %s: stiffness
    %(For default values check the function definition.)
    if nargin<=0, m = 0.1; end %mass
    if nargin<=1, k = 1; end %damping
    if nargin<=2, b = 0.2; end %stiffness
    A = [0 1;-k/m -b/m];
    B = [0; 1/m];
    C = [1 0];
    D = [0];
    y=ss(A,B,C,D);
end

