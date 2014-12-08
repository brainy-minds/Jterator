from subprocess import (PIPE, Popen)
from jterator.error import JteratorError

from IPython.core.debugger import Tracer


class Module(object):
    '''
    Main component of any Jterator pipeline. Able to handle IO streams and
    form a linked list.

    Note: a lot of logic is re-thought and borrowed from github:ewiger/pipette.
    '''

    def __init__(self, name, executable_path, handles):
        '''
        Initiate a new Jterator module.

        :name:            Name or description of the module, it may differ
                          from the corresponding executable. Cannot have white
                          spaces.

        :executable_path: a path to a program file that can be executed.

        :handles:         is FileObj instance, i.e. it can behave like an
                          opened file.
        '''
        self.name = name
        self.executable_path = executable_path
        # Require 'handles' to be a file object.
        if not hasattr(handles, 'read'):
            raise JteratorError('Passed argument \'handles\' is not a file '
                                'object.')
        self.handles = handles
        # Effectively, these are used as arguments for Popen call.
        # That's why it is actually legal to use PIPE as a default value here.
        # Note: Set values to None to avoid interaction with the program.
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
        Use "executable" property to figure out what would be the location of
        the program. Return it without further arguments. Everything else is
        parametrized using "handles".
        '''
        # Tracer()()
        return self.executable_path

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
        Execute a module as a bash command. Path to handles file as input.
        Log output and/or errors.
        '''
        command = self.bake_command()
        command = '''/bin/bash <<EOF
%s
EOF
        ''' % command
        print command
        try:
            process = Popen(command,
                            stdin=self.streams['input'],
                            stdout=self.streams['output'],
                            stderr=self.streams['error'],
                            #shell=True,
            )
                # TODO: review this for cases where that might not be needed.
                # executable='bin/bash'
            # Prepare handles input.
            input_data = None
            if self.streams['input'] == PIPE:
                input_data = self.handles.read()
            # Execute sub-process.
            (stdoutdata, stderrdata) = process.communicate(input=input_data)
            print stdoutdata
            # Write output and errors.
            self.write_output_and_errors(stdoutdata, stderrdata)
            # Close STDIN file descriptor.
            process.stdin.close
            # Take care of any errors during the execution.
            if process.returncode > 0:
                raise JteratorError(self.get_error_message(process,
                                    input_data))
        except ValueError as error:
            raise JteratorError('Failed running \'%s\'. Reason: \'%s\'' %
                                (command, str(error)))

    def __str__(self):
        return ':%s: @ <%s>' % (self.name, self.executable_path)
