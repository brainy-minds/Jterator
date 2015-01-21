from __future__ import unicode_literals
import sys
import yaml
import h5py
from jterator.error import JteratorError

# from IPython.core.debugger import Tracer

def gethandles(handles_stream):
    '''
    Reading "handles" from YAML file.
    '''
    mfilename = sys._getframe().f_code.co_name
    handles = yaml.load(handles_stream)

    print('jt -- %s: loaded \'handles\'' % mfilename)

    return handles


def readinputargs(handles):
    '''
    Reading input arguments from HDF5 file
    using the location specified in "handles".
    '''
    mfilename = sys._getframe().f_code.co_name

    hdf5_filename = handles['hdf5_filename']
    hdf5_root = h5py.File(hdf5_filename, 'r+')

    input_args = dict()
    for key in handles['input']:
        field = handles['input'][key]
        input_args[key] = dict()

        if 'hdf5_location' in field:
            # note: we index into the dataset to retrieve its content,
            # otherwise it would be loaded as hdf5 object
            input_args[key]['variable'] = hdf5_root[field['hdf5_location']][()]
            print('jt -- %s: loaded dataset \'%s\' from HDF5 group: "%s"'
                  % (mfilename, key, field['hdf5_location']))
        elif 'parameter' in field:
            input_args[key]['variable'] = field['parameter']
            print('jt -- %s: parameter \'%s\': "%s"'
                  % (mfilename, key, str(field['parameter'])))
        else:
            h5py.File.close(hdf5_root)
            raise JteratorError('Possible variable keys are '
                                '\'hdf5_location\' or \'parameter\'')

        if 'class' in field:
            input_args[key]['class'] = field['class']

        if 'attributes' in field:
            input_args[key]['attributes'] = field['attributes']

    h5py.File.close(hdf5_root)

    return input_args


def checkinputargs(input_args):
    '''
    Checks input arguments for correct class (i.e. type).
    '''
    mfilename = sys._getframe().f_code.co_name

    checked_input_args = dict()
    for key in input_args:

        # checks are only done if "class" is specified
        if 'class' in input_args[key]:
            expected_class = input_args[key]['class']
            loaded_class = type(input_args[key]['variable'])

            if 'h5py' in str(loaded_class):
                loaded_class = input_args[key]['variable'].dtype
            else:
                loaded_class = loaded_class.__name__

            if str(loaded_class) != expected_class:
                raise JteratorError('argument \'%s\' is of "class" \'%s\' '
                                    'instead of expected \'%s\''
                                    % (key, loaded_class, expected_class))

            print('jt -- %s: argument \'%s\' passed check' % (mfilename, key))

        else:
            print('jt -- %s: argument \'%s\' not checked' % (mfilename, key))

        # return parameters in simplified form
        checked_input_args[key] = input_args[key]['variable']

    return checked_input_args


def writedata(handles, data):
    '''
    Writing data to HDF5 file.
    '''
    mfilename = sys._getframe().f_code.co_name
    # Extract filename of the data HDF5 file.
    hdf5_tmp = h5py.File(handles['hdf5_filename'], 'r')
    hdf5_filename = hdf5_tmp['datafile'][()]
    h5py.File.close(hdf5_tmp)
    # Open the file and write data into it.
    hdf5_data = h5py.File(hdf5_filename, 'r+')
    for key in data:
        hdf5_location = handles['output'][key]['hdf5_location']
        hdf5_data.create_dataset(hdf5_location, data=data[key])
        print('jt -- %s: wrote dataset \'%s\' to HDF5 group: "%s"'
              % (mfilename, key, hdf5_location))
    # Close the file (very important!).
    h5py.File.close(hdf5_data)


def writeoutputargs(handles, output_args):
    '''
    Writing output arguments to HDF5 file
    using the location specified in "handles".
    '''
    mfilename = sys._getframe().f_code.co_name
    # Open the file and write temporary pipeline data into it.
    hdf5_tmp = h5py.File(handles['hdf5_filename'], 'r+')
    for key in output_args:
        hdf5_location = handles['output'][key]['hdf5_location']
        hdf5_tmp.create_dataset(hdf5_location, data=output_args[key])
        print('jt -- %s: wrote tmp dataset \'%s\' to HDF5 group: "%s"'
              % (mfilename, key, hdf5_location))
    # Close the file (very important!).
    h5py.File.close(hdf5_tmp)