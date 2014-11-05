## Jterator

require(rhdf5)
require(yaml)


handles <- yaml.load_file("/Users/Markus/Documents/Jterator/tests/mock/testPipe_example/handles/IllumCorr.handles")


mfilename = "get_handles"
values = list()
for (key in names(handles$input_keys)) {
  values[key] = handles$input_keys[[key]]$value
  cat(sprintf("jt -- %s: value '%s': \"%s\"\n",
                      mfilename, key, values[key]))
}


mfilename = "read_input_args"

hdf5_filename = handles$hdf5_filename

input_args = list()
for (key in names(handles$input_keys)) {
  field = handles$input_keys[[key]]
  input_args[[key]] = list()
  if ("hdf5_location" %in% names(field)) {
    input_args[[key]]$variable = h5read(hdf5_filename, field$hdf5_location)
    cat(sprintf("jt -- %s: loaded dataset '%s' from HDF5 group: \"%s\"\n",
            mfilename, key, field$hdf5_location))
  }
  else if ("parameter" %in% names(field)) {
    input_args[[key]]$variable = field$parameter
    cat(sprintf("jt -- %s: parameter '%s': \"%s\"\n",
                mfilename, key, paste(field$parameter, collapse=",")))
  }
  
  if ("class" %in% names(field)) {
    input_args[[key]]$class = field$class
  }
  
  if ("attributes" %in% names(field)) {
    input_args[[key]]$attributes = field$attributes
  }
}





mfilename = "check_input_args"

checked_input_args = list()
for (key in names(input_args)) {
  field = input_args[[key]]
  
  if ("class" %in% names(field)) {
    expected_class = input_args[[key]]$class
    loaded_class = class(input_args[[key]]$variable)
    
#     if (expected_class != loaded_class) {
#       stop(sprintf("argument '%s' is of \"class\" '%s' instead of expected '%s'", 
#                    key, loaded_class, expected_class))
#     }
    cat(sprintf("jt -- %s: argument '%s' passed check\n", mfilename, key))
  }
  else {
    cat(sprintf("jt -- %s: argument '%s' not checked\n", mfilename, key))
  }
  
  # return parameters in simplified form
  checked_input_args[[key]] = input_args[[key]]$variable
}


output_args = list()
output_args$CorrImage = seq(1:5)

mfilename = "write_output_args"

hdf5_filename = handles$hdf5_filename

for (key in names(output_args)) {
  hdf5_location = handles$output_keys[[key]]$hdf5_location
  h5createDataset(hdf5_filename, hdf5_location, 
                  dims = dim(output_args[[key]]),
                  storage.mode = storage.mode(output_args[[key]]))
  h5write(output_args[[key]], hdf5_filename, hdf5_location)
}



jt_path = "/Users/Markus/Documents/Jterator"
sourceDir <- function(path, trace = TRUE, ...) {
  for (nm in list.files(path, pattern = "io\\.R$", recursive = TRUE)) {
    print(nm)
#     if(trace) cat(nm, ":")
#     source(file.path(path, nm), ...)
#     if(trace) cat("\n")
  }
}
Rpath = source(list.files(jt_path, pattern = "io\\.R$", full.names = TRUE, recursive = TRUE)[[1]])



