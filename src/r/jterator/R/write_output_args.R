write_output_args <-
function(handles, output_args) {

    mfilename <- "write_output_args"

    hdf5_filename <- handles$hdf5_filename

    for (key in names(output_args)) {
      hdf5_location <- handles$output_keys[[key]]$hdf5_location
      h5createDataset(hdf5_filename, hdf5_location, 
                      dims = dim(output_args[[key]]),
                      storage.mode = storage.mode(output_args[[key]]))
      h5write(output_args[[key]], hdf5_filename, hdf5_location)
      cat(sprintf("jt -- %s: wrote dataset '%s' to HDF5 group: \"%s\"\n",
                mfilename, key, field$hdf5_location))
    }
}
