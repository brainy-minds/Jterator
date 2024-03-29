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

    required_keys <- c("name", "value", "class")

    input_args <- list()
    for (arg in handles$input) {
      key <- arg$name
      for (k in required_keys) {
        if (!(k %in% names(arg))) {
          stop(sprintf("Input argument '%s' requires '%s' key.", key, k))
        }
      }

      input_args[[key]] <- list()
      if (arg$class == "hdf5_location") {
        input_args[[key]]$variable <- h5read(hdf5_filename, arg$value)
        cat(sprintf("jt -- %s: loaded dataset '%s' from HDF5 location: \"%s\"\n",
                mfilename, key, arg$value))
        if (!is.null(dim(input_args[[key]]$variable))) {
          input_args[[key]]$variable <- t(input_args[[key]]$variable)
        }
      }
      else if (arg$class == "parameter") {
        input_args[[key]]$variable <- arg$value
        cat(sprintf("jt -- %s: parameter '%s': \"%s\"\n",
                    mfilename, key, paste(arg$value, collapse=",")))
      }
      else {
        stop("Possible variable keys are \'hdf5_location\' or \'parameter\'")
      }

      if ("type" %in% names(arg)) {
        input_args[[key]]$type <- arg$type
      }
    }

    return(input_args)
}


#' Jterator API. 
#' Checks input arguments for correct type.
#'
#' @param input_args List of input arguments.
#' @return List of checked input arguments.
checkinputargs <- function(input_args) {

    mfilename <- "checkinputargs"

    checked_input_args <- list()
    for (key in names(input_args)) {
      field <- input_args[[key]]
      
      if ("type" %in% names(field)) {
        expected_type <- input_args[[key]]$type
        loaded_type <- typeof(input_args[[key]]$variable)
        
        if (expected_type != loaded_type) {
          stop(sprintf("argument '%s' is of \"type\" '%s' instead of expected '%s'", 
                       key, loaded_type, expected_type))
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
      if (!is.null(dim(data[[key]]))) {
        out <- t(data[[key]])
      }
      else {
        out <- data[[key]]
      }
      hdf5_location <- key
      h5createDataset(hdf5_filename, hdf5_location, 
                      dims = dim(out),
                      storage.mode = storage.mode(out))
      h5write(out, hdf5_filename, hdf5_location)
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
      if (!is.null(dim(output_args[[key]]))) {
        out <- t(output_args[[key]])
      }
      else {
        out <- output_args[[key]]
      }
      ix <- which(sapply(handles$output, function(x) x$name == key))
      hdf5_location <- handles$output[[ix]]$value
      h5createGroup(hdf5_filename, dirname(hdf5_location))
      h5createDataset(hdf5_filename, hdf5_location, 
                      dims = dim(out),
                      storage.mode = storage.mode(out))
      h5write(out, hdf5_filename, hdf5_location)
      cat(sprintf("jt -- %s: wrote tmp dataset '%s' to HDF5 location: \"%s\"\n",
                mfilename, key, hdf5_location))
    }
}
