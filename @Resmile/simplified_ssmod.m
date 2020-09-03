function sm = simplified_ssmod(me, scheduling_parameter)
    % Return `SSmod` of the splines resulting from `simplify`, based on the given `scheduling_parameter` which is a `SchedulingParameter` object.
    % This object can be used for LPV control design using the LC Toolbox.
    splines = me.simplified_splines;
    example_ssmod = me.input_data.training_models{1};
    A=splines(1:size(example_ssmod.A,1),1:size(example_ssmod.A,2));
    B=splines(1:size(example_ssmod.B,1),size(example_ssmod.A,2)+1:end);
    C=splines(size(example_ssmod.B,1)+1:end,1:size(example_ssmod.A,2));
    D=splines(size(example_ssmod.B,1)+1:end,size(example_ssmod.A,2)+1:end);
    %E=eye(size(A))
    sm = SSmod(A, B, C, D, scheduling_parameter, me.input_data.training_models{1}.Ts);
