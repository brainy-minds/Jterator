function handles = get_handles(handles_filename)

    import jterator.api.json.*;

    % Reading handles from standard input as JSON.
    handles = loadjson(handles_filename);

end
