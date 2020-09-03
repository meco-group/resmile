function analyze_random(me)
    % Calculate error for random models of type `DSRAND_CLEAN` and `DSRAND_CLEANW`.

    % TODO this should be tested
    theta_values = sol.value(coeff_tensor(basis_function));
    me.input_data.clean_model_coeff_matrix;
    %TODO: these should match after actually removing the knots and retransforming the problem
    knot_indexes_ident = [1 size(theta_values,1)];
    knot_indexes_original = [1 size(me.input_data.clean_model_coeff_matrix,1)];

    %TODO this doesn't really make sense as we should really compare with the final splines we've got after simplification
    if(size(me.input_data.clean_model_coeff_matrix,1)==size(theta_values,1))
        disp('Full diff between original and identified splines'' coeff matrices')
        for i=1:size(me.input_data.clean_model_coeff_matrix,1)
            i
            theta_values_i = squeeze(theta_values(i,:,:))
            clean_model_coeff_matrix_i = squeeze(me.input_data.clean_model_coeff_matrix(i,:,:))
            diff_i = theta_values_i - clean_model_coeff_matrix_i
        end
    else
        for i = 1:length(knot_indexes_ident)
            disp(['Differences between original and identified splines'' coeff matrices for knot #' num2str(knot_indexes_ident(i)) ':'])
            squeeze(theta_values(knot_indexes_ident(i),:,:))-squeeze(me.input_data.clean_model_coeff_matrix(knot_indexes_original(i),:,:))
        end
    end
