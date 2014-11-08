%% Reading "handles" from YAML file.

function handles = get_handles(handles_stream, fid)

    % import jterator.api.json.*;
    import yaml.*;

    % Reading handles from YAML.
    handles = ReadYaml(handles_stream);

    fprintf(fid, sprintf('jt -- %s: loaded ''handles''\n', ...
            mfilename));

end
