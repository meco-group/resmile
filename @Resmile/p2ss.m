function yssmod = p2ss(p,example_ssmod)
    %The P matrix contains the [A B;C D] matrices from the state space
    %representation. This function converts from a P matrix to a `genss` model.
    %To be able to know the original sizes of A,B,C,D, it needs an example
    %model `example_ssmod`. In the resulting `genss` object, the matrices will be
    %the same size as in `example_ssmod`. In addition, the sampling time (Ts) will be
    %the same as in `example_ssmod`.
    A=p(1:size(example_ssmod.A,1),1:size(example_ssmod.A,2));
    B=p(1:size(example_ssmod.B,1),size(example_ssmod.A,2)+1:end);
    C=p(size(example_ssmod.B,1)+1:end,1:size(example_ssmod.A,2));
    D=p(size(example_ssmod.B,1)+1:end,size(example_ssmod.A,2)+1:end);
    yssmod=ss(A,B,C,D,example_ssmod.Ts);
end

