function build_hdf5(handles)

    import jterator.api.h5.*;

    filename = handles.hdf5_filename;

    h5filecreate(filename);

    % we could return the file indentifier
    
end
