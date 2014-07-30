function handles = get_handles(pipe_name)
    % Reading handles from standard input as JSON.
    handles = loadjson(pipe_name)
end

function input_args = read_input_args(handles)
    % Reading input arguments from HDF5 file
    % using the location specified in "handles".
    filename <- handles.hdf5_filename;

    input_args = {};
    keys = fieldnames(handles.input_keys);
    for key in 1:length(keys)
        location = handles.input_keys(key);
        input_args.(keys(key)) = h5read(filename,location);
    end
end

function write_output_args(handles, output_args)
    % Writing output arguments to HDF5 file
    % using the location specified in "handles".
    filename <- handles.hdf5_filename;

    keys = fieldnames(output_args);
    for key in 1:length(keys)
        location = handles.output_keys(key);
        value = output_args(keys);
        % works for strings, numbers, matrices and cell array of strings
        % (one could also implement structure arrays -> "Compound"
           % and cell arrays of matrices -> "Variable Length";
           % http://www.hdfgroup.org/ftp/HDF5/examples/examples-by-api/api18-m.html)
        h5datacreate(filename, location, 'type', class(value), 'size', size(value));
        h5varput(filename, location, output_args.keys(key));
    end
end
