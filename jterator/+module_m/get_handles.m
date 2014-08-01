function handles = get_handles(pipe_name)
    % Reading handles from standard input as JSON.
    handles = loadjson(pipe_name)
end
