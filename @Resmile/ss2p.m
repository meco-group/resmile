function p = ss2p(ssmod)
    %The P matrix contains the [A B;C D] matrices from the state space
    %representation. This function converts from an `ss` model to a P matrix. 
    p = [ssmod.A ssmod.B;ssmod.C ssmod.D];
end

