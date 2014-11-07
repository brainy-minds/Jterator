build_hdf5 <-
function(handles) {

    mfilename <- "build_hdf5"

    hdf5_filename <- handles$hdf5_filename;
    file_created <- h5createFile(hdf5_filename)
    cat(sprintf("jt -- %s: created HDF5 file: \"%s\"\n",
                mfilename, hdf5_filename))
}
