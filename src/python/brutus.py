#!/usr/bin/env python
import os
import yaml
import re
from subprocess32 import (PIPE, Popen, call)

'''
Script to run a Jterator pipeline in parallel mode on Brutus.

Call this script from your project folder!
'''

# 1) Create joblist
process = Popen(['jt', 'joblist'], stdin=PIPE, stdout=PIPE, stderr=PIPE)

(stdoutdata, stderrdata) = process.communicate()
print stdoutdata
print stderrdata

if process.returncode > 0 or re.search('Failed', stderrdata):
    raise Exception("""Building joblist failed.\n
Reason: \'%s\'""" % str(stderrdata))

if not os.path.exists('lsf'):
    os.mkdir('lsf')

# 2) Run 'PreCluster'
print('\njt - Submitting PreCluster')
lsf = os.path.abspath(os.path.join('lsf', '%.5d.precluster' % 1))
call(['bsub', '-W', '8:00', '-o', lsf,
     '-R', 'rusage[mem=4000,scratch=4000]',
     'jt', 'run', '--job', '1'])



# # 3) Run 'JTCluster'
# print('\njt - Submit JTCluster')
# project = os.path.dirname(os.path.realpath(__file__))
# joblist_filename = '%s.jobs' % project
# joblist = yaml.load(open(joblist_filename))

# if not os.path.exists('lsf'):
#     os.mkdir('lsf')

# for job in joblist:
#     lsf = os.path.abspath(os.path.join('lsf', '%.5d.jtcluster' % job['jobid']))
#     call(['bsub', '-W', '8:00', '-o', lsf,
#          '-R', 'rusage[mem=4000,scratch=4000]',
#          'jt', 'run', '--job', job['jobid']])
