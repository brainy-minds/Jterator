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

print '>>>>> loading "myImage" from "%s"' % myImageFilename
myImage = np.array(misc.imread(myImageFilename), dtype='float64')

print('>>>>> "myImage" has type "%s" and dimensions "%s".' %
      (str(myImage.dtype), str(myImage.shape)))

print '>>>>> position [1, 2] (0-based): %d' % myImage[1, 2]

data = dict()
output_args = dict()
output_args['OutputVar'] = myImage

##########
# output #
##########

writedata(handles, data)
writeoutputargs(handles, output_args)
