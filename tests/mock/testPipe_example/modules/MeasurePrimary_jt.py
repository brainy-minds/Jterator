#!/usr/bin/env python
import os
import sys
import numpy as np
import matplotlib.pyplot as plt
import mpld3 as d3
from skimage import measure
from jterator.api.io import *

# from IPython.core.debugger import Tracer


print('jt - %s:' % os.path.basename(__file__))

### read actual input argument
handles_stream = sys.stdin  # sys.argv[1]


###############################################################################
## jterator input

### retrieve handles from .JSON files
handles = get_handles(handles_stream)

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
nuclei_img = np.array(input_args['Nuclei'])


################
## processing ##
################

### get object ids and total number of objects
nuclei_ids = np.unique(nuclei_img)
nuclei_num = nuclei_ids.shape[0]

### measure object properties
nuclei_label_img = measure.label(nuclei_img)
regions = measure.regionprops(nuclei_label_img)

### extract "area" measurement
nuclei_area = [regions[i].area for i in range(nuclei_num)]


#################
## make figure ##
#################

plt.plot(nuclei_area)

### show figure in the browser: yeah!
# d3.show_d3()

####################
## prepare output ##
####################

output_args = dict()
output_args['Measurements'] = nuclei_area

# ------------------------------ module specific ------------------------------
## ----------------------------------------------------------------------------


###############################################################################
## jterator output

write_output_args(handles, output_args)

###############################################################################
