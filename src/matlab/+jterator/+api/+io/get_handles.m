%% Reading "handles" from YAML file.

function handles = get_handles(handles_stream)

    % import jterator.api.json.*;
    import yaml.*;

    % Reading handles from YAML.
    handles = ReadYaml(handles_stream);

    fprintf('jt -- %s: loaded ''handles''\n', ...
            mfilename)

end
