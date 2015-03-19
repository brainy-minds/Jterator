import re
import os
from subprocess import (PIPE, Popen)


def invoke(command, _in=None):
    '''
    Invoke command as a new system process and return its output.
    '''
    process = Popen(command, stdin=PIPE, stdout=PIPE, shell=True,
                    executable='/bin/bash')
    if _in is not None:
        process.stdin.write(_in)
    return process.stdout.read()


def complete_yaml_path(input_path, variable):
    '''
    Complete module path, which can be provided in the pipeline descriptor
    file as full path, relative path or `variable` path (containing
    the variable {libpath}).
    :input_path:   value of the key in the pipeline descriptor file
    :variable:     value of the key in the pipeline descriptor file
    '''
    # Replace the `variable` name with the actual value
    if variable and re.search(r'.*{.*}.*', input_path):
        re_path = re.sub(r'{%s}' % variable, variable, input_path)
    else:
        re_path = input_path
    # Expand path starting with `~`
    complete_path = os.path.expanduser(re_path)
    return complete_path
