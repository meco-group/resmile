function set_input(me, what)
    % Setter for `Resmile.input_data`
    if strcmp(class(what),'Gridmod')
        me.set_input(Resmile.load_grid(what));
    else
        me.input_data = what;
    end
end
