function write_output_args(handles, output_args)
    % Writing output arguments to HDF5 file
    % using the location specified in "handles".
    filename <- handles.hdf5_filename;

    keys = fieldnames(output_args);
    for key in 1:length(keys)
        location = handles.output_keys(key).hdf5_location;
        value = output_args(keys);
        % works for strings, numbers, matrices and cell array of strings
        % (one could also implement structure arrays -> "Compound"
           % and cell arrays of matrices -> "Variable Length";
           % http://www.hdfgroup.org/ftp/HDF5/examples/examples-by-api/api18-m.html)
        h5datacreate(filename, location, 'type', class(value), 'size', size(value));
        h5varput(filename, location, output_args.keys(key));
    end
end
