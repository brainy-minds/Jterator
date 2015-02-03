#!/usr/bin/env python
import os
import yaml
import mmap
import time
import datetime
import glob
from subprocess32 import call


'''
'JTCluster submission.

After checking that the PreCluster step finished successfully, all jobs are
send out for parallel processing.
'''


def check_precluster(lsf_file):
    if len(lsf_file) == 0:
        raise Exception('\nNo PreCluster lsf files found.')
    f = open(lsf_file)
    s = mmap.mmap(f.fileno(), 0, access=mmap.ACCESS_READ)
    if s.find('Failed. Error message') != -1:
        failed = True
    else:
        failed = False
    f.close()
    return failed


# 1) Check results of 'PreCluster' step
lsf_file = glob.glob('lsf/*.precluster')
lsf_file = lsf_file[-1]  # take the latest

failed = check_precluster(lsf_file)
if failed:
    raise Exception('\n--> PreCluster step failed!')
else:
    print('jt - PreCluster step successfully completed')

# 2) Run 'JTCluster' step
print('jt - JTCluster submission:')
joblist_filename = glob.glob(os.path.join(os.getcwd(), '*.jobs'))[0]
joblist = yaml.load(open(joblist_filename))

for job in joblist.itervalues():
    print('jt - Submitting job # %d' % job['jobID'])
    ts = time.time()
    st = datetime.datetime.fromtimestamp(ts).strftime('%Y-%m-%d_%H-%M-%S')
    lsf = os.path.abspath(os.path.join('lsf',
                          '%.5d_%s.jtcluster' % (job['jobID'], st)))
    call(['bsub', '-W', '8:00', '-o', lsf,
         '-R', 'rusage[mem=4000,scratch=4000]',
         'jt', 'run', '--job', '%s' % job['jobID']])
