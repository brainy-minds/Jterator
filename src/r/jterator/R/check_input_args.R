check_input_args <-
function(input_args) {

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
