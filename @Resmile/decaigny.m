function output_models = decaigny(input_models, gramian_enabled)
    % Transforms state-space models to the same basis.
    % Apply balreal on the input state-space models if `gramian_enabled`. 

    %The first input model's timestep will be copied to all the outputs.
    
    if gramian_enabled, input_models = cellfun(@(x)balreal(x), input_models, 'UniformOutput', false); end

    %% Computing observability/controllability matrices and selecting the reference model

    O = zeros(size(input_models{1}.A,1)*size(input_models{1}.C,1),size(input_models{1}.A,1),numel(input_models));
    C = zeros(size(input_models{1}.A,1),size(input_models{1}.A,1)*size(input_models{1}.B,2),numel(input_models));
    for i = 1:numel(input_models)  
        O(:,:,i) = obsv(input_models{i}.A,input_models{i}.C); 
        C(:,:,i) = ctrb(input_models{i}.A,input_models{i}.B);
    end
    [kappaOmax, kappaCmax] = deal(zeros(1,numel(input_models)));
    [To, Tc, T_o, T_c] = deal(zeros(size(input_models{1}.A,1),size(input_models{1}.A,2),numel(input_models)));
    for i = 1:numel(input_models)
       [kappaO, kappaC] = deal(zeros(1,numel(input_models)));
       for k = 1:numel(input_models)   
          To(:,:,k) = (((O(:,:,i)')*O(:,:,i))^(-1))*(O(:,:,i)')* O(:,:,k);
          Tc(:,:,k) =  C(:,:,k)*(((C(:,:,i)')*C(:,:,i))^(-1))*(C(:,:,i)');
          kappaO(i) = cond(To(:,:,k));
          kappaC(i) = cond(Tc(:,:,k));
       end
       kappaOmax(i) = max(kappaO);
       kappaCmax(i) = max(kappaC); 
    end
    [minKappaO, iO] = min(kappaOmax);
    [minKappaC, iC] = min(kappaCmax);

    %% Similarity matrices for observability and controllability

    [sys_co(numel(input_models)), sys_cc(numel(input_models))] = deal(struct('A',[],'B',[],'C',[],'D',[]));
     for i = 1:numel(input_models)
        T_o(:,:,i) = ((((O(:,:,iO)')*O(:,:,iO))^(-1))* (O(:,:,iO)'))* O(:,:,i);
        sys_co(i).A = T_o(:,:,i)*input_models{i}.A*(T_o(:,:,i)^(-1));
        sys_co(i).B = T_o(:,:,i)*input_models{i}.B;
        sys_co(i).C = input_models{i}.C*(T_o(:,:,i)^(-1));
        sys_co(i).D = input_models{i}.D;   
        T_c(:,:,i) = C(:,:,iC)*((((C(:,:,i)')*C(:,:,i))^(-1))*(C(:,:,i)'));
        sys_cc(i).A = T_c(:,:,i)*input_models{i}.A*(T_c(:,:,i)^(-1));
        sys_cc(i).B = T_c(:,:,i)*input_models{i}.B;
        sys_cc(i).C = input_models{i}.C*(T_c(:,:,i)^(-1));
        sys_cc(i).D = input_models{i}.D;    
     end

    %% Choosing the set easier to interpolate

    if minKappaC < minKappaO
        sys_chosen = sys_cc;
        fprintf([ mfilename ': Controllability-based transformation\n'])
    else
        sys_chosen = sys_co;
        fprintf([ mfilename ': Observability-based transformation\n'])
    end

    output_models = {};
    for i=1:length(sys_chosen)
        output_models{i} = ss(sys_chosen(i).A,sys_chosen(i).B,sys_chosen(i).C,sys_chosen(i).D,input_models{1}.Ts);
    end

end


