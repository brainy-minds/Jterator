function2 <- function(input_args){

require(rhdf5)


# first input argutent is hdf5 filename
hdf5_file <- input_args[1]

# further input arguments are locations in hdf5 file
input_group <- input_args[2]
input_data <- h5read(hdf5_file, input_group)

#--------------------------------------------------------------------

# processing
output_data <- input_data

#--------------------------------------------------------------------

# last input argument is location of output in hdf5 file 
h5write(output_data, hdf5_file, tail(input_args, n=1))

}