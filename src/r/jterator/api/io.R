library(rhdf5)
library(yaml)


#' Reading "handles" from YAML file.
function get_handles(handles_filename) {

    handles = yaml.load_file(handles_filename)

    return(handles)
}


#' Reading initial values from "handles".
function read_input_values(handles) {

}


#' Reading input arguments from HDF5 file
#' using the location specified in "handles".
function read_input_args(handles) {

}


#' Checks input arguments for correct class and attributes.
function check_input_args(input_args) {

}


#' Writing output arguments to HDF5 file
#' using the location specified in "handles".
function write_output_args(handles, output_args) {

}
