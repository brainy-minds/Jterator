#!/usr/bin/env python
# encoding: utf-8

import os
import yaml
from jterator.error import JteratorError
import jterator.utils as util


class JteratorCheck(object):

    def __init__(self, pipe_description, tmp_filename):
        '''
        Initiate checks of pipeline and handles structure.
        '''
        self.description = pipe_description
        self.tmp_filename = tmp_filename

    def check_pipeline(self):
        '''
        Check pipeline structure.
        '''
        # Check required 'project' section
        if 'project' not in self.description:
            raise JteratorError('Pipeline file must contain the key "%s".' %
                                'project')
        if 'name' not in self.description['project']:
            raise JteratorError('Pipeline file must contain the key "%s" '
                                'as a subkey of "%s"' %
                                ('name', 'project'))
        if 'libpath' in self.description['project']:
            libpath = self.description['project']['libpath']
            libpath = os.path.expanduser(libpath)
            if not os.path.exists(libpath):
                raise JteratorError('The path defined by "%s" in your '
                                    'pipeline description is not valid.'
                                    % 'libpath')
        # Check required 'jobs' section
        if 'jobs' not in self.description:
            raise JteratorError('Pipeline file must contain the key "%s".' %
                                'jobs')
        if 'folder' not in self.description['jobs']:
            raise JteratorError('Pipeline file must contain the key "%s" '
                                'as a subkey of "%s"' %
                                ('folder', 'jobs'))
        if 'pattern' not in self.description['jobs']:
            raise JteratorError('Pipeline file must contain the key "%s" '
                                'as a subkey of "%s"' %
                                ('pattern', 'jobs'))
        if not type(self.description['jobs']['pattern']) is list:
            raise JteratorError('The key "pattern" in the pipeline file '
                                'must contain a list.')
        for pattern_description in self.description['jobs']['pattern']:
            if 'name' not in pattern_description:
                raise JteratorError('Each element of the list in "pattern" '
                                    'in the pipeline descriptor file '
                                    'needs to contain the key "%s"' %
                                    'name')
            if 'expression' not in pattern_description:
                raise JteratorError('Each element of the list in "pattern" '
                                    'in the pipeline descriptor file '
                                    'needs to contain the key "%s"' %
                                    'expression')
        # Check required 'pipeline' section
        if 'pipeline' not in self.description:
            raise JteratorError('Pipeline file must contain the key "%s".' %
                                'pipeline')
        if not type(self.description['pipeline']) is list:
            raise JteratorError('The key "pipeline" in the pipeline file '
                                'must contain a list.')
        for module_description in self.description['pipeline']:
            if 'name' not in module_description:
                raise JteratorError('Each element of the list in "pipeline" '
                                    'in the pipeline descriptor file '
                                    'needs to contain the key "%s"' %
                                    'name')
            if 'handles' not in module_description:
                raise JteratorError('Each element of the list in "pipeline" '
                                    'in the pipeline descriptor file '
                                    'needs to contain the key "%s"' %
                                    'handles')
            if 'module' not in module_description:
                raise JteratorError('Each element of the list in "pipeline" '
                                    'in the pipeline descriptor file '
                                    'needs to contain the key "%s"' %
                                    'module')
            if 'interpreter' not in module_description:
                raise JteratorError('Each element of the list in "pipeline" '
                                    'in the pipeline descriptor file '
                                    'needs to contain the key "%s"' %
                                    'interpreter')
        print('🍺   Pipeline check successful!')

    def check_handles(self):
        '''
        Check handles structure.
        '''
        for module in self.description['pipeline']:
            # Check whether files exist
            module_path = module['module']
            libpath = self.description['project']['libpath']
            module_path = util.complete_yaml_path(module_path, libpath)
            # module_path = os.path.expanduser(module_path)
            if not os.path.exists(module_path):
                raise JteratorError('Module file "%s" does not exist.' %
                                    module_path)
            if not os.path.exists(module['handles']):
                raise JteratorError('Handles file "%s" does not exist.' %
                                    module['handles'])
            try:
                handles = yaml.load(open(module['handles']).read())
            except Exception as e:
                raise JteratorError('Could not read handles file "%s".\n'
                                    'Original error message:\n%s' %
                                    (module['handles'], str(e)))
            # Check required keys
            required_keys = ['hdf5_filename', 'input', 'output']
            for key in required_keys:
                if key not in handles:
                    raise JteratorError('Handles file must contain the key '
                                        '"%s".' % key)
            required_subkeys = ['name', 'value', 'class']
            for input_arg in handles['input']:
                for key in required_subkeys:
                    if key not in input_arg:
                        raise JteratorError('Input argument in handles file '
                                            '"%s" misses required key "%s".' %
                                            (module['handles'], key))
            for output_arg in handles['output']:
                for key in required_subkeys:
                    if key not in output_arg:
                        raise JteratorError('Output argument in handles file '
                                            '"%s" misses required key "%s".' %
                                            (module['handles'], key))
        print('🍺   Handles check successful!')

    def check_pipeline_io(self):
        '''
        Ensure that module inputs have been produced upstream in the pipeline.
        '''
        outputs = list()
        for module in self.description['pipeline']:
            handles = yaml.load(open(module['handles']).read())
            # Store all upstream output arguments
            if handles['output'] is None:
                continue
            for output_arg in handles['output']:
                if output_arg['class'] != 'hdf5_location':
                    continue
                output = output_arg['value']
                outputs.append(output)
            # Check whether input arguments for current module were produced
            # upstream in the pipeline
            for input_arg in handles['input']:
                if input_arg['class'] != 'hdf5_location':
                    # We only check for pipeline data passed via the HDF5 file.
                    continue
                name = os.path.basename(input_arg['value'])
                pattern_names = [pattern['name'] for pattern
                                 in self.description['jobs']['pattern']]
                if name in pattern_names:
                    # These names are written into the HDF5 file by Jterator
                    # and are therefore not created in the pipeline.
                    # So there is no need to check them here.
                    continue
                if input_arg['value'] not in outputs:
                    raise JteratorError('Input "%s" of module "%s" is not '
                                        'created upstream in the pipeline.' %
                                        (input_arg['name'], module['name']))
        print('🍺   Input/output check successful!')
