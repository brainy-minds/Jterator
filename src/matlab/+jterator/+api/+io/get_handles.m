%% Reading "handles" from YAML file.

function handles = get_handles(handles_stream)

    % import jterator.api.json.*;
    import jterator.api.yaml.*;

    % % Reading handles from JSON.
    % handles = loadjson(handles_stream);

    % Reading handles from YAML.
    handles = ReadYaml(handles_stream);

    fprintf('jt -- %s: loaded ''handles'' from "%s"\n', ...
            mfilename, handles_stream)

end
