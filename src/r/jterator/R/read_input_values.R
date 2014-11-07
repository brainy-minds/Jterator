read_input_values <-
function(handles) {

    mfilename <- "read_input_values"

    values <- list()
    for (key in names(handles$input_keys)) {
      values[key] <- handles$input_keys[[key]]$value
      cat(sprintf("jt -- %s: value '%s': \"%s\"\n",
                  mfilename, key, values[key]))
    }

    return(values)
}
