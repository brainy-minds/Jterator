%% Create HDF5 file.
function build_hdf5(handles)

    import jterator.api.h5.*;

    hdf5_filename = handles.hdf5_filename;
    h5filecreate(hdf5_filename);
    fprintf(sprintf('jt -- %s: created HDF5 file for measurement data: "%s"\n', ...
            mfilename, hdf5_filename));

    hdf5_filename = regexprep(handles.hdf5_filename, ...
                              '/data/(.*)\.data$', '/tmp/$1\.tmp');
    h5filecreate(hdf5_filename);
    fprintf(sprintf('jt -- %s: created HDF5 file for temporary pipe data: "%s"\n', ...
            mfilename, hdf5_filename));

end
