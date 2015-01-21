import os
import sys
import re
import numpy as np
from scipy.io import loadmat
from jterator.api import *


mfilename = re.search('(.*).py', os.path.basename(__file__)).group(1)

###############################################################################
## jterator input

print("jt - %s:" % mfilename)

### read YAML from standard input
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

orig_image = np.array(input_args["DapiImage"])
stats_directory = input_args["StatsDirectory"]
stats_filename = input_args["StatsFilename"]


################
## processing ##
################

### build absolute path to illumination correction file
stats_path = os.path.join(stats_directory, stats_filename)
if not os.path.isabs(stats_path):
    stats_path = os.path.join(os.getcwd(), stats_path)
### load illumination correction file and extract statistics
stats = loadmat(stats_path)
# this works in principle, but always hangs when I run the module
stats = stats['stat_values']
mean_image = np.array(stats['mean'])
std_image = np.array(stats['std'])

### correct intensity image for illumination artefact
orig_image[orig_image == 0] = 1
corr_image = (np.log10(orig_image) - mean_image) / std_image
corr_image = (corr_image * mean(std_image)) + mean(mean_image)
corr_image = 10 ** corr_image


#################
## make figure ##
#################


####################
## prepare output ##
####################

output_args = dict()
output_args["CorrImage"] = corr_image
data = dict()


## ------------------------------ module specific -----------------------------
## ----------------------------------------------------------------------------


###############################################################################
## jterator output

### write measurement data to HDF5
writedata(handles, data)

### write temporary pipeline data to HDF5
writeoutputargs(handles, output_args)

###############################################################################
