import os
import sys
import re
import numpy as np
from scipy import misc
from jterator.api import *

# from IPython.core.debugger import Tracer


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

dapi_filename = input_args['DapiFilename']
celltrace_filename = input_args['CelltraceFilename']


################
## processing ##
################

dapi_image = np.float64(misc.imread(dapi_filename))
celltrace_image = np.float64(misc.imread(celltrace_filename))


#####################
## display results ##
#####################


####################
## prepare output ##
####################

output_args = dict()
output_args['DapiImage'] = dapi_image
output_args['CelltraceImage'] = celltrace_image

data = dict()


###############################################################################
## jterator output

### write measurement data to HDF5
writedata(handles, data)

### write temporary pipeline data to HDF5
writeoutputargs(handles, output_args)

###############################################################################
