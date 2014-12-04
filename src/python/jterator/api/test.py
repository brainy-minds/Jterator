#!/usr/bin/env python
import os
import sys
import fileinput
import StringIO

matlab_script_path = '/Users/Markus/Documents/Jterator/tests/mock/testPipe_example/modules/PrimeRawData_jt.m'

matlab_script = ''
for line in fileinput.input(matlab_script_path):
    if line.startswith('#'):
        continue
    matlab_script += line

print(matlab_script)

# output = StringIO.StringIO()
# for line in fileinput.input(matlab_script_path):
#     if line.startswith('#'):
#         continue
#     output.write(line)
# matlab_script = output.getvalue()

command = 'matlab -nosplash -nodesktop -r "\'%s\'"' % matlab_script
os.system(command)
