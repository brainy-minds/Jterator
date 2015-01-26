#!/usr/bin/env python
import os
import yaml
import mmap
import time
import re
import glob
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
print('jt - PreCluster submission:')
print('jt - Job # %d' % 1)
lsf = os.path.abspath(os.path.join('lsf', '%.5d.precluster' % 1))
call(['bsub', '-W', '8:00', '-o', lsf,
     '-R', 'rusage[mem=8000,scratch=8000]',
     'jt', 'run', '--job', '1'])

# 3) Check results of 'PreCluster' step
while True:
    if os.path.exists(lsf):
        f = open(lsf)
        s = mmap.mmap(f.fileno(), 0, access=mmap.ACCESS_READ)
        if s.find('Failed') != -1:
            failed = True
        else:
            failed = False
        f.close()
        break
    else:
        print('jt - PreCluster step running...')
        time.sleep(30)

if failed:
    raise Exception('PreCluster step failed')
else:
    print('jt - PreCluster step successfully completed')

# 4) Run 'JTCluster'
print('jt - JTCluster Submission:')
joblist_filename = glob.glob(os.path.join(os.getcwd(), '*.jobs'))[0]
joblist = yaml.load(open(joblist_filename))

for job in joblist:
    print('jt - Job # %d' % job['jobid'])
    lsf = os.path.abspath(os.path.join('lsf', '%.5d.jtcluster' % job['jobid']))
    call(['bsub', '-W', '8:00', '-o', lsf,
         '-R', 'rusage[mem=8000,scratch=8000]',
         'jt', 'run', '--job', job['jobid']])
