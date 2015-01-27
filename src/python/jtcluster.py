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


def check_precluster(lsf):
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
    return(failed)


# 1) Check results of 'PreCluster' step
lsf = glob.glob('lsf/*.precluster')
lsf = lsf[-1]  # take the latest

failed = check_precluster(lsf)
if failed:
    raise Exception('\n--> PreCluster step failed!')
else:
    print('jt - PreCluster step successfully completed')

# 2) Run 'JTCluster' step
print('jt - JTCluster Submission:')
joblist_filename = glob.glob(os.path.join(os.getcwd(), '*.jobs'))[0]
joblist = yaml.load(open(joblist_filename))

for job in joblist:
    print('jt - Submitting job # %d' % job)
    ts = time.time()
    st = datetime.datetime.fromtimestamp(ts).strftime('%Y-%m-%d_%H-%M-%S')
    lsf = os.path.abspath(os.path.join('lsf',
                          '%.5d_%s.jtcluster' % (job, st)))
    call(['bsub', '-W', '8:00', '-o', lsf,
         '-R', 'rusage[mem=4000,scratch=4000]',
         'jt', 'run', '--job', int(job)])
