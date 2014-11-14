#!/usr/bin/env python
import os
import sys
import re
from jterator.api.io import *


mfilename = re.search('(.*).py', os.path.basename(__file__)).group(1)

###############################################################################
## jterator input

print('jt - %s:' % mfilename)

### standard input
handles_stream = sys.stdin

### retrieve handles from .YAML files
handles = get_handles(handles_stream)

### read input arguments from .HDF5 files
input_args = read_input_args(handles)

### check whether input arguments are valid
input_args = check_input_args(input_args)

###############################################################################


## ----------------------------------------------------------------------------
## ------------------------------ module specific -----------------------------

####################
## input handling ##
####################


################
## processing ##
################


#################
## make figure ##
#################


####################
## prepare output ##
####################

output_args = dict()
output_tmp = dict()

## ------------------------------ module specific -----------------------------
## ----------------------------------------------------------------------------


###############################################################################
## jterator output

### write output data to HDF5
write_output_args(handles, output_args)
write_output_tmp(handles, output_tmp)

###############################################################################
