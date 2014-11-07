%% Reading "handles" from YAML file.

function handles = get_handles(handles_filename)

    % import jterator.api.json.*;
    import jterator.api.yaml.*;

    % % Reading handles from JSON.
    % handles = loadjson(handles_filename);

    % Reading handles from YAML.
    handles = ReadYaml(handles_filename);

    fprintf('jt -- %s: loaded ''handles''\n', ...
            mfilename)

end
