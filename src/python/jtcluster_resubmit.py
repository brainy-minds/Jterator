#!/usr/bin/env python
import os
import yaml
import time
import datetime
import glob
import re
from subprocess32 import call


'''
'JTCluster re-submission.

Checking JTCluster files and re-submission in case of 'Errors'.
'''


def check_jtcluster(lsf_files):
    error_files = list()
    for lsf in lsf_files:
        for line in open(lsf, 'r'):
            if re.search('Failed', line):
                error_files.append(lsf)
    return error_files


# 1) Check results of 'JTCluster' step
lsf_files = glob.glob('lsf/*.jtcluster')
error_files = check_jtcluster(lsf_files)
if len(error_files) == 0:
    raise Exception('\nNo errors found in JTCluster lsf files')
else:
    print('jt - %d JtCluster jobs with errors found' % len(error_files))

# 2) Identify jobs that should be re-submitted
resubmit = list()
for error_file in error_files:
    tmp = int(re.search('([0-9]+)_\d{4}-\d{2}-\d{2}_', error_file).group(1))
    resubmit.append(tmp)

# 3) Re-submit 'JTCluster' step
joblist_filename = glob.glob(os.path.join(os.getcwd(), '*.jobs'))[0]
joblist = yaml.load(open(joblist_filename))
print('jt - JTCluster re-submission:')
for job in joblist.itervalues():
    if job['jobID'] in resubmit:
        print('jt - Submitting job # %d' % job['jobID'])
        ts = time.time()
        st = datetime.datetime.fromtimestamp(ts).strftime('%Y-%m-%d_%H-%M-%S')
        lsf = os.path.abspath(os.path.join('lsf',
                              '%.5d_%s.jtcluster' % (job['jobID'], st)))
        call(['bsub', '-W', '8:00', '-o', lsf,
             '-R', 'rusage[mem=4000,scratch=4000]',
             'jt', 'run', '--job', '%s' % job['jobID']])
