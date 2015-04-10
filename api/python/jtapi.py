from __future__ import unicode_literals
import sys
import yaml
import h5py
import urlparse
import urllib
import webbrowser
from jterator.error import JteratorError


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

    required_keys = ['name', 'value', 'class']

    input_args = dict()
    for arg in handles['input']:
        key = arg['name']
        # Make sure that required keys are provided
        for k in required_keys:
            if k not in arg:
                raise JteratorError('Input argument \'%s\' requires '
                                    'a \'%s\' key.' % (key, k))

        input_args[key] = dict()

        if arg['class'] == 'hdf5_location':
            # Note: we index into the dataset to retrieve its content,
            # otherwise it would be loaded as hdf5 object
            input_args[key]['variable'] = hdf5_root[arg['value']][()]
            print('jt -- %s: loaded dataset \'%s\' from HDF5 location: "%s"'
                  % (mfilename, key, arg['value']))
        elif arg['class'] == 'parameter':
            input_args[key]['variable'] = arg['value']
            print('jt -- %s: parameter \'%s\': "%s"'
                  % (mfilename, key, str(arg['value'])))
        else:
            hdf5_root.close()
            raise JteratorError('Possible values for \'class\' key are '
                                '\'hdf5_location\' or \'parameter\'')

        if 'type' in arg:
            # Optional key
            input_args[key]['type'] = arg['type']

    hdf5_root.close()

    return input_args


def checkinputargs(input_args):
    '''
    Checks input arguments for correct type (i.e. type).
    '''
    mfilename = sys._getframe().f_code.co_name

    checked_input_args = dict()
    for key in input_args:

        # checks are only done if "type" key is specified
        if 'type' in input_args[key]:
            expected_type = input_args[key]['type']
            loaded_type = type(input_args[key]['variable'])

            if 'h5py' in str(loaded_type):
                loaded_type = input_args[key]['variable'].dtype
            else:
                loaded_type = loaded_type.__name__

            # hack around numpy data type issue
            if str(loaded_type) == 'ndarray':
                loaded_type = input_args[key]['variable'].dtype

            if str(loaded_type) != expected_type:
                raise JteratorError('argument \'%s\' is of "type" \'%s\' '
                                    'instead of expected \'%s\''
                                    % (key, loaded_type, expected_type))

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
    hdf5_tmp.close()
    # Open the file and write data into it.
    hdf5_data = h5py.File(hdf5_filename, 'r+')
    for key in data:
        hdf5_location = key
        hdf5_data.create_dataset(hdf5_location, data=data[key])
        print('jt -- %s: wrote dataset \'%s\' to HDF5 location: "%s"'
              % (mfilename, key, hdf5_location))
    # Close the file (very important!).
    hdf5_data.close()


def writeoutputargs(handles, output_args):
    '''
    Writing output arguments to HDF5 file
    using the location specified in "handles".
    '''
    mfilename = sys._getframe().f_code.co_name
    # Open the file and write temporary pipeline data into it.
    hdf5_tmp = h5py.File(handles['hdf5_filename'], 'r+')
    for key in output_args:
        hdf5_location = [x['value'] for x in handles['output']
                            if x['name'] == key
                            and x['class'] == 'hdf5_location'][0]
        hdf5_tmp.create_dataset(hdf5_location, data=output_args[key])
        print('jt -- %s: wrote tmp dataset \'%s\' to HDF5 location: "%s"'
              % (mfilename, key, hdf5_location))
    # Close the file (very important!).
    hdf5_tmp.close()


def figure2browser(path):
    '''
    Creating a url for a html file and opening it in the default browser.
    '''
    url = urlparse.urljoin('file:', urllib.pathname2url(path))
    webbrowser.get("open %s").open(url)
