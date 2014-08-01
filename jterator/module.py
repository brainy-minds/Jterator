import sys
import json
import h5py as h5
from jterator.error import JteratorError


def get_handles():
    '''
    Reading "handles" from standard input as JSON.
    '''
    handles = json.loads(sys.stdin.read())

    return handles


def read_input_args(handles):
    '''
    Reading input arguments from HDF5 file
    using the location specified in "handles".
    '''

    hdf5_root = h5.File(handles['hdf5_filename'], 'r')

    input_args = dict()
    for key in handles['input_keys']:
        location = handles['input_keys'][key]
        input_args[key] = hdf5_root[location]

    return input_args


def write_output_args(handles, output_args):
    '''
    Writing output arguments to HDF5 file
    using the location specified in "handles".
    '''

    hdf5_root = h5.File(handles['hdf5_filename'], 'r')

    for key in output_args:
        location = handles['output_keys'][key]
        hdf5_root.create_dataset(location, data=output_args[key])


class Module(object):
    '''
    Main component of any Jterator pipeline. Able to handle IO streams and
    form a linked list.

    Note: a lot of logic is re-thought and borrowed from github:ewiger/pipette.
    '''

    def __init__(self, name, executable_path, handles_filepath):
        self.name = name
        self.executable_path = executable_path
        self.handles = open(handles_filepath).read()
        # Effectively, these are used as arguments fr Popen call.That's why it
        # is actually legal to use PIPE as a default value here. Note: set
        # values to None to avoid respective interaction with the program.
        self.streams = {
            'input': PIPE,
            'output': PIPE,
            'error': PIPE,
        }

    def set_error_output(error_log_path):
        self.streams['error'] = open(error_log_path, 'w+')

    def set_standard_output(output_log_path):
        self.streams['error'] = open(output_log_path, 'w+')

    def bake_command(self):
        '''
        Use "executable" property to figure out what would be the location of
        the program. Return it without further arguments. Everything else is
        parametrized using "handles" in form of JSON STDIN.
        '''
        return self.executable_path

    def run(self):
        '''
        Execute a module as a bash command. Path handles as input. Log output
        and/or errors.
        '''
        command = self.bake_command()
        try:
            process = Popen(
                self.bake_command(),
                stdin=self.streams['input'],
                stdout=self.streams['output'],
                stderr=self.streams['error'],
                # TODO: review this for cases where that might not be needed.
                shell=True,
                executable='/bin/bash')
            if self.streams['input'] == PIPE:
                process.communicate(input=open(self.handles).read())
            else:
                process.wait()
            # Flush streams.
            if process.output:
                process.output.flush()
            if process.error:
                process.error.flush()
        except ValueError as error:
            raise JteratorError('Failed running \'%s\'. Reason: \'%s\'' %
                                (command, cstr(error))
