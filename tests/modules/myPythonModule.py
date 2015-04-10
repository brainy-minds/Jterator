from jtapi import *
import os
import sys
import re


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

InputVar1 = input_args['InputVar1']

print('>>>>> "InputVar1" has type "%s" and dimensions "%s".' %
      (str(InputVar1.dtype), str(InputVar1.shape)))


data = dict()
output_args = dict()
output_args['OutputVar'] = InputVar1


##########
# output #
##########

writedata(handles, data)
writeoutputargs(handles, output_args)
