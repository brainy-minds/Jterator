import os
import time
import datetime
import re
from subprocess32 import (PIPE, Popen, call)


# 1) Create joblist
process = Popen(['jt', 'joblist'], stdin=PIPE, stdout=PIPE, stderr=PIPE)

(stdoutdata, stderrdata) = process.communicate()
print stdoutdata
print stderrdata

if process.returncode > 0 or re.search('Failed', stderrdata):
    raise Exception('\n--> Building joblist failed!')

if not os.path.exists('lsf'):
    os.mkdir('lsf')

# 2) Run 'PreCluster'
ts = time.time()
st = datetime.datetime.fromtimestamp(ts).strftime('%Y-%m-%d_%H-%M-%S')
lsf = os.path.abspath(os.path.join('lsf', '%.5d_%s.precluster' % (1, st)))
if not os.path.exists(lsf):
    print('jt - PreCluster submission:')
    call(['bsub', '-W', '8:00', '-o', lsf,
         '-R', 'rusage[mem=4000,scratch=4000]',
         'jt', 'run', '--job', '1'])
