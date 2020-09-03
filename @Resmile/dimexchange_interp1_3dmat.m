function y=dimexchange_interp1_3dmat(x,direction)
    %It exchanges dimensions of a 3D matrix, because for `interp1_3dmat`
    %the scheduling parameter (index) is the first dimension, and for B-spline
    %interpolation, the scheduling parameter (index) is the 3rd dimension. 
    %If the `direction` is 'forward', then the dimensions are exchanged as:
    % [S,X,Y] -> [X,Y,S]
    %If the `direction` is 'backward', then the dimensions are exchanged as:
    % [X,Y,S] -> [S,X,Y]
    
    if strcmp(direction,'backward')
        for i=1:size(x,3)
            y(i,:,:)=x(:,:,i);
        end
    elseif strcmp(direction,'forward')
        for i=1:size(x,1)
            y(:,:,i)=x(i,:,:);
        end
    else
        error('invalid direction')
    end
        
end