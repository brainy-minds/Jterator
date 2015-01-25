#!/usr/bin/env python
import os
import yaml
import re
from subprocess32 import (PIPE, Popen, call)

'''
Script to run Jterator in parallel on Brutus.

Call this script from your project folder!
'''


# 1) Check pipeline
process = Popen(['jt', 'check'], stdin=PIPE, stdout=PIPE, stderr=PIPE)

(stdoutdata, stderrdata) = process.communicate()
print stdoutdata
print stderrdata

if process.returncode > 0 or re.search('Failed', stderrdata):
    raise Exception("""Pipeline check failed.\n
Reason: \'%s\'""" % str(stderrdata))

# 2) Create joblist
process = Popen(['jt', 'joblist'], stdin=PIPE, stdout=PIPE, stderr=PIPE)

(stdoutdata, stderrdata) = process.communicate()
print stdoutdata
print stderrdata

if process.returncode > 0 or re.search('Failed', stderrdata):
    raise Exception("""Building joblist failed.\n
Reason: \'%s\'""" % str(stderrdata))

# 3) Run 'PreCluster'
process = Popen(['jt', 'run', '--job', '1'], stdin=PIPE, stdout=PIPE, stderr=PIPE)

(stdoutdata, stderrdata) = process.communicate()
print stdoutdata
print stderrdata

if process.returncode > 0 or re.search('Failed', stderrdata):
    raise Exception("""PreCluster step failed.\n
Reason: \'%s\'""" % str(stderrdata))

# 4) Run 'Cluster'
project = os.path.dirname(os.path.realpath(__file__))
joblist_filename = '%s.jobs' % project
joblist = yaml.load(open(joblist_filename))

if not os.path.exists('lsf'):
    os.mkdir('lsf')

for job in joblist:
    lsf = os.path.abspath(os.path.join('lsf', '%d.result' % job['jobid']))
    call(['bsub', '-W', '8:00', '-o', lsf,
         'jt', 'run', '--job', job['jobid']])
