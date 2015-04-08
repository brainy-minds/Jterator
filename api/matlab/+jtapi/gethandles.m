%% Reading "handles" from YAML file.

function handles = gethandles(handles_stream)

    import yaml.*;

    % Reading handles from YAML.
    handles = ReadYaml(handles_stream, 0, 0, 1);

    fprintf(sprintf('jt -- %s: loaded ''handles''\n', ...
            mfilename));

end
