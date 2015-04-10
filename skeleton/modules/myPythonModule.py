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

# here comes your code

data = dict()
output_args = dict()


##########
# output #
##########

writedata(handles, data)
writeoutputargs(handles, output_args)
