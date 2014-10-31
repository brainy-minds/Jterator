import sys
import json
import h5py as h5


def get_handles(handles_filename):
    '''
    Reading "handles" from standard input as JSON.
    '''
    handles = json.load(open(sys.argv[1])) # json.loads(sys.stdin.read())
    return handles


def read_input_args(handles):
    '''
    Reading input arguments from HDF5 file
    using the location specified in "handles".
    '''

    hdf5_root = h5.File(handles['hdf5_filename'], 'r')

    input_args = dict()
    for key in handles['input_keys']:
        location = handles['input_keys'][key]['hdf5_location']
        input_args[key] = dict()
        input_args[key]['data'] = hdf5_root[location]
        input_args[key]['class'] = handles['input_keys'][key]['class']
        input_args[key]['attributes'] = handles['input_keys'][key]['attributes']

    return input_args


def check_input_args(input_args):
    '''
    Checks input arguments for class and attributes.
    '''

    # how do I check for "type" consistent over different languages?
    # (e.g. Matlab -> Python: 'double' -> 'float64', 'string' -> '|S1')
    for key in input_args:
        print input_args[key]['data'].dtype



def write_output_args(handles, output_args):
    '''
    Writing output arguments to HDF5 file
    using the location specified in "handles".
    '''

    hdf5_root = h5.File(handles['hdf5_filename'], 'r')

    for key in output_args:
        location = handles['output_keys'][key]
        hdf5_root.create_dataset(location, data=output_args[key])
