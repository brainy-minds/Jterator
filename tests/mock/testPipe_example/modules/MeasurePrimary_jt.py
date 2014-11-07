#!/usr/bin/env python
import os
import sys
import re
import numpy as np
import matplotlib.pyplot as plt
# import mpld3
import plotly.plotly as py
from plotly.graph_objs import *
from skimage import measure
from jterator.api.io import *

from IPython.core.debugger import Tracer

mfilename = re.search('(.*).py', os.path.basename(__file__)).group(1)
print('jt - %s:' % mfilename)

### standard input
handles_stream = sys.stdin

###############################################################################
## jterator input

### retrieve handles from .YAML files
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

### make a histogram
plt.hist(nuclei_area)
plt.title("Nuclear area")
plt.xlabel("Area in pixel")
plt.ylabel("Number of cells")

### send figure to plotly
# fig = plt.gcf()
# plot_url = py.plot_mpl(fig, filename='mpl-basic-histogram')

### alternatively, one can use mpld3
# mpld3.show_d3()


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
