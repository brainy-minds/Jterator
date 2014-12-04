#!/usr/bin/env python
import os
import subprocess
import sys
import yaml
import json
import fileinput
import StringIO


def build_matlab_script(matlab_script_path):
    '''
    Builds MATLAB script (string) from .m file.
    '''
    output = StringIO.StringIO()
    for line in fileinput.input(matlab_script_path):
        if line.startswith('#'):
            continue
        output.write(line)
    matlab_script = output.getvalue()
    return matlab_script


def build_matlab_command(matlab_script):
    '''
    Builds MATLAB command with full path to script.
    '''
    command = 'matlab -nosplash -nodesktop -r "run(\'%s\')"'
    command = command % matlab_script
    return command


def pipe_yaml_json():
    '''
    Reads YAML stream from standard input and converts it to JSON string.
    '''
    pipe_input = yaml.load(sys.stdin)
    pipe_output = json.dumps(pipe_input)
    return pipe_output


if __name__ == '__main__':
    # build MATLAB script
    matlab_script_path = os.path.abspath(__file__)
    matlab_script = build_matlab_script(matlab_script_path)
    # build MATLAB command
    matlab_command = build_matlab_command(matlab_script_path)
    # prepare standard input for MATLAB
    matlab_stdin = pipe_yaml_json()
    # call MATLAB command and pass standard input
    subprocess.call(matlab_command, stdin=matlab_stdin, shell=True)
