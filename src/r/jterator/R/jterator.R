#' Jterator API. 
#' Reading "handles" stream from YAML file.
#'
#' @param handles_stream YAML stream from standard input.
#' @return List of module input/output information.
gethandles <- function(handles_stream) {

    require(yaml)

    mfilename <- "gethandles"
    handles <- yaml.load_file(handles_stream)

    cat(sprintf("jt -- %s: loaded 'handles'\n", 
                mfilename))

    return(handles)
}


#' Jterator API. 
#' Reading input arguments from HDF5 file
#' using the locations specified in "handles".
#'
#' @param handles List of module input/output information.
#' @return List of input arguments read from HDF5 file.
readinputargs <- function(handles) {

    require(rhdf5)

    mfilename <- "readinputargs"

    hdf5_filename <- handles$hdf5_filename

    input_args <- list()
    for (key in names(handles$input)) {
      field <- handles$input[[key]]
      input_args[[key]] <- list()

      if ("hdf5_location" %in% names(field)) {
        input_args[[key]]$variable <- h5read(hdf5_filename, field$hdf5_location)
        cat(sprintf("jt -- %s: loaded dataset '%s' from HDF5 location: \"%s\"\n",
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


#' Jterator API. 
#' Checks input arguments for correct class and attributes.
#'
#' @param input_args List of input arguments.
#' @return List of checked input arguments.
checkinputargs <- function(input_args) {

    mfilename <- "checkinputargs"

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


#' Jterator API. 
#' Writing data to HDF5 file using the location specified in "handles".
#'
#' @param handles List of module input/output information.
#' @param List of data output arguments that should be written to HDF5 file.
writedata <- function(handles, data) {

    require(rhdf5)

    mfilename <- "writedata"

    hdf5_filename <- h5read(handles$hdf5_filename, '/datafile')

    for (key in names(data)) {
      hdf5_location <- key
      h5createDataset(hdf5_filename, hdf5_location, 
                      dims = dim(data[[key]]),
                      storage.mode = storage.mode(data[[key]]))
      h5write(data[[key]], hdf5_filename, hdf5_location)
      cat(sprintf("jt -- %s: wrote dataset '%s' to HDF5 location: \"%s\"\n",
                mfilename, key, hdf5_location))
    }
}

#' Jterator API. 
#' Writing output arguments to HDF5 file using the location specified in "handles".
#'
#' @param handles List of module input/output information.
#' @param List of temporary pipeline output arguments that should be written to HDF5 file.
writeoutputargs <- function(handles, output_args) {

    require(rhdf5)

    mfilename <- "writeoutputargs"

    hdf5_filename <- handles$hdf5_filename

    for (key in names(output_args)) {
      hdf5_location <- handles$output[[key]]$hdf5_location
      h5createGroup(hdf5_filename, dirname(hdf5_location))
      h5createDataset(hdf5_filename, hdf5_location, 
                      dims = dim(output_args[[key]]),
                      storage.mode = storage.mode(output_args[[key]]))
      h5write(output_args[[key]], hdf5_filename, hdf5_location)
      cat(sprintf("jt -- %s: wrote tmp dataset '%s' to HDF5 location: \"%s\"\n",
                mfilename, key, hdf5_location))
    }
}
