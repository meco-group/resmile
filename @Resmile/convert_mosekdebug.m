function convert_mosekdebug
    % Convert Mosek debugging information into readable files.
    load mosekdebug
    mosekopt('write(mosekdebug.opf)', prob);
    mosekopt('write(mosekdebug.mps)', prob);
    mosekopt('anapro', prob);
