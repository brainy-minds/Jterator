function input_args = read_input_args(handles)

    import jterator.api.h5.*;

    % Reading input arguments from HDF5 file
    % using the location specified in "handles".
    filename = handles.hdf5_filename;

    input_args = struct();
    keys = fieldnames(handles.input_keys);
    for i = 1:length(keys)
        location = handles.input_keys.(keys{i}).hdf5_location;
        input_args.((keys{i})).data = h5varget(filename, location);
        input_args.(keys{i}).class = {handles.input_keys.(keys{i}).class};
        input_args.(keys{i}).attributes = handles.input_keys.(keys{i}).attributes;
    end
    
end
