%% Create HDF5 file.
function build_hdf5(handles)

    import jterator.api.h5.*;

    hdf5_filename = handles.hdf5_filename;
    h5filecreate(hdf5_filename);
    fprintf('jt -- %s: created HDF5 file: "%s"\n', mfilename, hdf5_filename)

end
