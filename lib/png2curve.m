function curve = png2curve(filename)
    % Converts a black&white PNG file into a curve.
    %   It returns the index of the first black element in every column.
    A=imread("spline_deboor_input.png");
    curve=sum(~(A(:,:,1)/255),1);
end

