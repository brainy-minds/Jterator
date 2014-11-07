read_input_args <-
function(handles) {

    mfilename <- "read_input_args"

    hdf5_filename <- handles$hdf5_filename

    input_args <- list()
    for (key in names(handles$input_keys)) {
      field <- handles$input_keys[[key]]
      input_args[[key]] <- list()

      if ("hdf5_location" %in% names(field)) {
        input_args[[key]]$variable <- h5read(hdf5_filename, field$hdf5_location)
        cat(sprintf("jt -- %s: loaded dataset '%s' from HDF5 group: \"%s\"\n",
                mfilename, key, field$hdf5_location))
      }
      else if ("parameter" %in% names(field)) {
        input_args[[key]]$variable <- field$parameter
        cat(sprintf("jt -- %s: parameter '%s': \"%s\"\n",
                    mfilename, key, paste(field$parameter, collapse=",")))
      }
      else {
        stop("Possible variable keys are \'hdf5_location\' or \'parameter\'")
      }

      if ("class" %in% names(field)) {
        input_args[[key]]$class <- field$class
      }
      
      if ("attributes" %in% names(field)) {
        input_args[[key]]$attributes <- field$attributes
      }
    }

    return(input_args)
}
