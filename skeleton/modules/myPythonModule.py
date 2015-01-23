from jterator.api import *
import os
import sys
import re


mfilename = re.search('(.*).py', os.path.basename(__file__)).group(1)

###############################################################################
## jterator input

print('jt - %s:' % mfilename)

### standard input
handles_stream = sys.stdin

### retrieve handles from .YAML files
handles = gethandles(handles_stream)

### read input arguments from .HDF5 files
input_args = readinputargs(handles)

### check whether input arguments are valid
input_args = checkinputargs(input_args)

###############################################################################


####################
## input handling ##
####################


################
## processing ##
################


#####################
## display results ##
#####################


####################
## prepare output ##
####################

output_args = dict()
output_tmp = dict()


###############################################################################
## jterator output

### write output data to HDF5
writeoutputargs(handles, output_args)
writeoutputtmp(handles, output_tmp)

###############################################################################
