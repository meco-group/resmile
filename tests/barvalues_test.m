function barvalues_test
    % Test for `barvalues`
    barvalues([1 5 4 0 9 8 2 11 7 3],rand(10,1))
    disp("press any key"); pause
    barvalues(rand(10,1))
