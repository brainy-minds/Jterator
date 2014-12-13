%% Writing data to HDF5 file

function writedata(handles, data)

    import jterator.api.h5.*;
    

    hdf5_filename = h5varget(handles.hdf5_filename, '/datafile');

    % Works for strings, numbers, matrices and cell array of strings.
    % One could also implement structure arrays -> "Compound"
    % and cell arrays of matrices -> "Variable Length",
    % but it gets pretty complicates then.
    % For examples see:
    % http://www.hdfgroup.org/ftp/HDF5/examples/examples-by-api/api18-m.html

    keys = fieldnames(data);
    for key = 1:length(keys)
        hdf5_location = handles.output.(keys{key}).hdf5_location;
        value = data.(keys{key});
        h5datacreate(hdf5_filename, hdf5_location, ...
                     'type', class(value), 'size', size(value));
        h5varput(hdf5_filename, hdf5_location, value);
        fprintf(sprintf('jt -- %s: wrote dataset ''%s'' to HDF5 group: "%s"\n', ...
                        mfilename, keys{key}, hdf5_location));
    end
end
