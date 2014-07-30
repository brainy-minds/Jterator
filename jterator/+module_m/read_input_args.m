function input_args = read_input_args(handles)
    % Reading input arguments from HDF5 file
    % using the location specified in "handles".
    filename <- handles.hdf5_filename;

    input_args = struct();
    keys = fieldnames(handles.input_keys);
    for key in 1:length(keys)
        location = handles.input_keys(key);
        input_args.(keys(key)) = h5read(filename,location);
    end
end
