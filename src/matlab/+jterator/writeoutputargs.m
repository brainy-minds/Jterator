%% Writing output arguments to HDF5 file
%% using the location specified in "handles".

function writeoutputargs(handles, output_args)

    import h5.*;
    

    hdf5_filename = handles.hdf5_filename;
    
    % Works for strings, numbers, matrices and cell array of strings.
    % One could also implement structure arrays -> "Compound"
    % and cell arrays of matrices -> "Variable Length",
    % but it gets pretty complicates then.
    % For examples see:
    % http://www.hdfgroup.org/ftp/HDF5/examples/examples-by-api/api18-m.html

    fid = H5F.open(hdf5_filename, 'H5F_ACC_RDWR','H5P_DEFAULT');

    keys = fieldnames(output_args);
    for key = 1:length(keys)
        hdf5_location = handles.output.(keys{key}).hdf5_location;
        value = output_args.(keys{key});
        h5datacreate(fid, hdf5_location, ...
                     'type', class(value), 'size', size(value));
        h5varput(fid, hdf5_location, value);
        fprintf(sprintf('jt -- %s: wrote tmp dataset ''%s'' to HDF5 location: "%s"\n', ...
                    mfilename, keys{key}, hdf5_location));
    end

    H5F.close(fid);
end
