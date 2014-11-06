library(yaml)
library(rhdf5)


#' Reading "handles" from YAML file.
get_handles <- function(handles_stream) {

    mfilename <- "get_handles"
    handles <- yaml.load_file(handles_stream)

    cat(sprintf("jt -- %s: loaded 'handles' from standard input\n", 
                mfilename))

    return(handles)
}


#' @rdname Reading initial values from "handles".
read_input_values <- function(handles) {

    mfilename <- "read_input_values"

    values <- list()
    for (key in names(handles$input_keys)) {
      values[key] <- handles$input_keys[[key]]$value
      cat(sprintf("jt -- %s: value '%s': \"%s\"\n",
                  mfilename, key, values[key]))
    }

    return(values)
}


#' @rdname Reading input arguments from HDF5 file using the location specified in "handles".
read_input_args <- function(handles) {

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


#' @rdname Checks input arguments for correct class and attributes.
check_input_args <- function(input_args) {

    mfilename <- "check_input_args"

    checked_input_args <- list()
    for (key in names(input_args)) {
      field <- input_args[[key]]
      
      if ("class" %in% names(field)) {
        expected_class <- input_args[[key]]$class
        loaded_class <- class(input_args[[key]]$variable)
        
        if (expected_class != loaded_class) {
          stop(sprintf("argument '%s' is of \"class\" '%s' instead of expected '%s'", 
                       key, loaded_class, expected_class))
        }
        cat(sprintf("jt -- %s: argument '%s' passed check\n", mfilename, key))
      }
      else {
        cat(sprintf("jt -- %s: argument '%s' not checked\n", mfilename, key))
      }
      
      # return parameters in simplified form
      checked_input_args[[key]] <- input_args[[key]]$variable
    }

    return(checked_input_args)
}


#' @rdname Writing output arguments to HDF5 file using the location specified in "handles".
write_output_args <- function(handles, output_args) {

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


#' @rdname Create HDF5 file.
build_hdf5 <- function(handles) {

    mfilename <- "build_hdf5"

    hdf5_filename <- handles$hdf5_filename;
    file_created <- h5createFile(hdf5_filename)
    cat(sprintf("jt -- %s: created HDF5 file: \"%s\"\n",
                mfilename, hdf5_filename))
}
