function res = interp1_3dmat(m,interp1_xq,interp1_method,interp1_x)
    %Interpolate 3D matrix `m` using `interp1` function of MATLAB along
    %dimension 3. Get a 2D matrix result for point `xq`.
    %For example, `xq` should be 1.5 to get the result just between the
    %first and second matrix.
    %Interpolation `method` can be given to underlying `interp1` (e.g.
    %"linear" or "cubic" can be set).
    %Optionally, `x` for `interp1` can also be given to this function via
    %`interp1_x`.
    
    if nargin<4, interp1_x=1:size(m,3); end
    res=zeros(size(m,1),size(m,2),length(interp1_xq));
    for x=1:size(m,1)
        for y=1:size(m,2)
            v=squeeze(m(x,y,:));
            res(x,y,:)=interp1(interp1_x,v,interp1_xq,interp1_method);
        end
    end
end

