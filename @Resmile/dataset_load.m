function dataset_load(me, mat_file)
    % Load dataset from MAT file into Resmile object.
    me.set_input(load(mat_file))
