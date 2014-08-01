#!/usr/local/bin/python

import sys
import getopt
import h5py as h5


# parse input arguments
optlist, input_args = getopt.getopt(sys.argv[1:])

# first input argutent is hdf5 filename
hdf5_file = h5.File(input_args[0], 'r')

# further input arguments are locations in hdf5 file
input_group = hdf5_file[input_args[1]]
input_data = input_group.values()

#--------------------------------------------------------------------

# processing
output_data = input_data

#--------------------------------------------------------------------

# last input argument is location of output in hdf5 file 
hdf5_file.create_dataset(input_args[-1], output_data) # shape, size, dtype