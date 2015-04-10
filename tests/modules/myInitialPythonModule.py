from jtapi import *
import os
import sys
import re
import numpy as np
from scipy import misc


mfilename = re.search('(.*).py', os.path.basename(__file__)).group(1)

#########
# input #
#########

print('jt - %s:' % mfilename)

handles_stream = sys.stdin
handles = gethandles(handles_stream)
input_args = readinputargs(handles)
input_args = checkinputargs(input_args)


##############
# processing #
##############

myImageFilename = input_args['myImageFilename']

myImage = np.array(misc.imread(myImageFilename), dtype='float64')

print('>>>>> "myImage" has type "%s" and dimensions "%s".' %
      (str(myImage.dtype), str(myImage.shape)))

data = dict()
output_args = dict()
output_args['OutputVar'] = myImage

##########
# output #
##########

writedata(handles, data)
writeoutputargs(handles, output_args)