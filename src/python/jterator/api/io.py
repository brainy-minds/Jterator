from __future__ import unicode_literals
import sys
import re
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
    for key in handles['input_keys']:
        field = handles['input_keys'][key]
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
    Checks input arguments for correct class (i.e. type) and attributes
    (attributes are not yet implemented).
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


def writeoutputargs(handles, output_args):
    '''
    Writing output arguments to HDF5 file
    using the location specified in "handles".
    '''
    mfilename = sys._getframe().f_code.co_name

    hdf5_filename = hdf5_filename = re.sub('/tmp/(.*)\.tmp$', '/data/\\1.data',
                           handles['hdf5_filename'])
    hdf5_root = h5py.File(hdf5_filename, 'r+')

    for key in output_args:
        hdf5_location = handles['output_keys'][key]['hdf5_location']
        hdf5_root.create_dataset(hdf5_location, data=output_args[key])
        print('jt -- %s: wrote dataset \'%s\' to HDF5 group: "%s"'
              % (mfilename, key, hdf5_location))

    h5py.File.close(hdf5_root)


def writeoutputtmp(handles, output_tmp):
    '''
    Writing output arguments to HDF5 file
    using the location specified in "handles".
    '''
    mfilename = sys._getframe().f_code.co_name

    hdf5_filename = handles['hdf5_filename']
    hdf5_root = h5py.File(hdf5_filename, 'r+')

    for key in output_tmp:
        hdf5_location = handles['output_keys'][key]['hdf5_location']
        hdf5_root.create_dataset(hdf5_location, data=output_tmp[key])
        print('jt -- %s: wrote tmp dataset \'%s\' to HDF5 group: "%s"'
              % (mfilename, key, hdf5_location))

    h5py.File.close(hdf5_root)


def buildhdf5(handles):
    '''
    Create HDF5 file.
    '''
    mfilename = sys._getframe().f_code.co_name

    hdf5_filename = handles['hdf5_filename']
    h5py.File(hdf5_filename, 'w')
    print('jt -- %s: created HDF5 file for temporary data: "%s"'
          % (mfilename, hdf5_filename))

    hdf5_filename = re.sub('/tmp/(.*)\.tmp$', '/data/\\1.data',
                           handles['hdf5_filename'])
    h5py.File(hdf5_filename, 'w')
    print('jt -- %s: created HDF5 file for measurement pipe data: "%s"'
          % (mfilename, hdf5_filename))
