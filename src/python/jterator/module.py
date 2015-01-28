import os
import re
import yaml
from subprocess32 import (PIPE, Popen)
from jterator.error import JteratorError


class Module(object):
    '''
    Building block of a Jterator pipeline.

    Note: a lot of logic is re-thought and borrowed from github:ewiger/pipette.
    '''

    def __init__(self, name, module, handles, interpreter, tmp_filename):
        '''
        Initiate a Jterator module.

        :name:            Name or description of the module, it may differ
                          from the corresponding interpreter. Cannot have white
                          spaces.

        :module:          Path to program file that should be executed.

        :handles:         Path to handles file that provides input/output info.

        :interpreter:     Path to program that should execute the program file.

        :tmp_filename:    Filename of the temporary HDF5 file.
        '''
        self.name = name
        self.module = module
        self.handles = handles
        self.interpreter = interpreter
        self.tmp_filename = tmp_filename
        self.streams = {
            'input': PIPE,
            'output': PIPE,
            'error': PIPE,
        }
        self.error_log_path = None
        self.output_log_path = None

    def set_error_output(self, error_log_path):
        self.error_log_path = error_log_path

    def set_standard_output(self, output_log_path):
        self.output_log_path = output_log_path

    def bake_command(self):
        '''
        Use "interpreter" property to figure out what would be the location of
        the program. Return it without further arguments. Everything else is
        parametrized using "handles".
        '''
        if os.path.isabs(self.interpreter):
            return [self.interpreter, self.module]
        else:
            return ['/usr/bin/env', self.interpreter, self.module]

    def get_error_message(self, process, input_data):
        message = ('Execution of module %s failed with error ' +
                   '(Return code: %s).') % \
                  (str(self), process.returncode)
        if self.error_log_path:
            if input_data is not None:
                message += '\n' + '---[ Handles input ]---' \
                    .ljust(80, '-') + '\n' + input_data
            message += '\n' + '---[ Standard output ]---' \
                .ljust(80, '-') + '\n' + \
                open(self.output_log_path).read()
            message += '\n' + '---[ Error output ]---' \
                .ljust(80, '-') + '\n' + \
                open(self.error_log_path).read()
        return message

    def write_output_and_errors(self, stdoutdata, stderrdata):
        if self.streams['output'] == PIPE and self.output_log_path:
            with open(self.output_log_path, 'w+') as output_log:
                output_log.write(stdoutdata)
        if self.streams['error'] == PIPE and self.error_log_path:
            with open(self.error_log_path, 'w+') as error_log:
                error_log.write(stderrdata)

    def run(self):
        '''
        Execute a module as a bash command. Open handles file object as input.
        Log output and/or errors.
        '''
        command = self.bake_command()
        try:
            process = Popen(command,
                            stdin=self.streams['input'],
                            stdout=self.streams['output'],
                            stderr=self.streams['error'])
            # Prepare handles input.
            input_data = None
            if self.streams['input'] == PIPE:
                input_data = open(self.handles).readlines()
                # We have to provide the temporary filename to the modules.
                i = -1
                for line in input_data:
                    i = i + 1
                    # Replace the value of the 'hdf5_filename' key.
                    # Doing this via YAML should be saver.
                    if re.match('hdf5_filename', line):
                        hdf5_key = yaml.load(line)
                        hdf5_key['hdf5_filename'] = self.tmp_filename
                        input_data[i] = yaml.dump(hdf5_key,
                                                  default_flow_style=False)
                # Create the new handles string.
                input_data = ''.join(input_data)
            # Execute sub-process.
            (stdoutdata, stderrdata) = process.communicate(input=input_data)
            # Write output and errors.
            self.write_output_and_errors(stdoutdata, stderrdata)
            # Modify for nicer output to command line.
            ignore_list = ['INFO:']
            if any([re.search(x, stderrdata) for x in ignore_list]):
                newstderrdata = str()
                for line in stderrdata.split('\n'):
                    if not any([re.search(x, line) for x in ignore_list]):
                        newstderrdata = newstderrdata + line
                stderrdata = newstderrdata
            print stdoutdata
            print stderrdata
            # Close STDIN file descriptor.
            process.stdin.close
            # Take care of any errors during the execution.
            if process.returncode > 0 or re.search('Error', stderrdata):
                raise JteratorError(self.get_error_message(process,
                                    input_data))
        except ValueError as error:
            raise JteratorError('Failed running \'%s\'. Reason: \'%s\'' %
                                (command, str(error)))

    def __str__(self):
        return ':%s: @ <%s>' % (self.name, self.module)
