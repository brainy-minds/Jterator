import os
import sys
import re
import numpy as np
import matplotlib.pyplot as plt
# import mpld3
# import plotly.plotly as py
from plotly.graph_objs import *
from skimage import measure
from jterator.api.io import *


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


## ----------------------------------------------------------------------------
## ------------------------------ module specific -----------------------------

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

### make figure with matplotlib
plt.hist(nuclei_area)
plt.title("Nuclear area")
plt.xlabel("Area in pixel")
plt.ylabel("Number of cells")

### save figure as PDF file
plt.savefig('figures/%s.pdf' % mfilename, format='pdf')
plt.close()

### send figure to plotly
# fig = plt.gcf()
# plot_url = py.plot_mpl(fig, filename='mpl-basic-histogram')

### alternatively, one can use mpld3
# mpld3.show_d3()


####################
## prepare output ##
####################

data = dict()
data['Measurements'] = nuclei_area

output_args = dict()
output_args['LabeledSegmentationImage'] = nuclei_label_img

## ------------------------------ module specific -----------------------------
## ----------------------------------------------------------------------------


###############################################################################
## jterator output

### write measurement data to HDF5
writedata(handles, data)

### write temporary pipeline data to HDF5
writeoutputargs(handles, output_args)

###############################################################################
