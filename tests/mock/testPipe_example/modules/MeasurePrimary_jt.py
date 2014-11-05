#!/usr/bin/env python
import os
import sys
import numpy as np
from jterator.api.io import *

# from IPython.core.debugger import Tracer


print('jt - %s:' % os.path.basename(__file__))

### read actual input argument
handles_filename = sys.argv[1]


###############################################################################
## jterator input

### retrieve handles from .JSON files
handles = get_handles(handles_filename)

### read input arguments from .HDF5 files
input_args = read_input_args(handles)

### check whether input arguments are valid
input_args = check_input_args(input_args)

###############################################################################


## ----------------------------------------------------------------------------
# ------------------------------ module specific ------------------------------

####################
## input handling ##
####################

### convert into numpy array
Nuclei = np.array(input_args['Nuclei'])


################
## processing ##
################

### get object ids
Measure = np.unique(Nuclei)


#################
## make figure ##
#################


####################
## prepare output ##
####################

output_args = dict()
output_args['Measurements'] = Measure

# ------------------------------ module specific ------------------------------
## ----------------------------------------------------------------------------


###############################################################################
## jterator output

write_output_args(handles, output_args)

###############################################################################
