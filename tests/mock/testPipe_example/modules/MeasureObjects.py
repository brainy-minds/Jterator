import os
import sys
import re
import numpy as np
import matplotlib.pyplot as plt
import plotly.plotly as py
from plotly.graph_objs import *
from skimage import measure
from jterator.api import *


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

objects = np.array(input_args['Objects'])

doPlot = input_args['doPlot']


################
## processing ##
################

### get object ids and total number of objects
object_ids = np.unique(objects)
object_ids = object_ids[object_ids!=0]  # remove '0' background
object_num = object_ids.shape[0]

### measure object properties
objects_labeled = measure.label(objects)
regions = measure.regionprops(objects_labeled)

### extract measured features
object_area = [regions[index].area for index in range(object_num)]


#####################
## display results ##
#####################

if doPlot:

    ### make figure with matplotlib
    plt.hist(object_area)
    plt.title("Cell area")
    plt.xlabel("Area in pixel")
    plt.ylabel("Cells")

    ### save figure as PDF file
    plt.savefig('figures/%s.pdf' % mfilename, format='pdf')
    plt.close()

    # ### send figure to plotly
    # fig = plt.gcf()
    # plot_url = py.plot_mpl(fig, filename='mpl-basic-histogram')


####################
## prepare output ##
####################

data = dict()
data['Measurements'] = object_area

output_args = dict()


###############################################################################
## jterator output

### write measurement data to HDF5
writedata(handles, data)

### write temporary pipeline data to HDF5
writeoutputargs(handles, output_args)

###############################################################################
