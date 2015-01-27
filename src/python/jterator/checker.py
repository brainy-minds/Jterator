import os
import yaml
from jterator.error import JteratorError

# from IPython.core.debugger import Tracer


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
        print('jt - Pipeline check successful!')

    def check_handles(self):
        '''
        Check handles structure.
        '''
        for module in self.description['pipeline']:
            # Check whether files exist
            if not os.path.exists(module['module']):
                raise JteratorError('Modules file "%s" does not exist.' %
                                    module['module'])
            if not os.path.exists(module['handles']):
                raise JteratorError('Handles file "%s" does not exist.' %
                                    module['handles'])
            handles = yaml.load(open(module['handles']).read())
            # Check required 'hdf5_filename' section
            if 'hdf5_filename' not in handles:
                raise JteratorError('Handles file must contain the key "%s".' %
                                    'hdf5_filename')
            # Check required 'input' section
            if 'input' not in handles:
                raise JteratorError('Handles file must contain the key "%s".' %
                                    'input')
            # Check required 'output' section
            if 'output' not in handles:
                raise JteratorError('Handles file must contain the key "%s".' %
                                    'output')
        print('jt - Handles check successful!')

    def check_pipeline_io(self):
        '''
        Ensure that module inputs have been produced upstream in the pipeline.
        '''
        outputs = list()
        for module in self.description['pipeline']:
            handles = yaml.load(open(module['handles']).read())
            if handles['output'] is not None:
                for output_arg in handles['output']:
                    output = handles['output'][output_arg]['hdf5_location']
                    outputs.append(output)
            for input_arg in handles['input']:
                if 'hdf5_location' not in handles['input'][input_arg]:
                    # We only check for pipeline data passed via the HDF5 file.
                    # So there is no need to check them here.
                    continue
                name = os.path.basename(handles['input'][input_arg]['hdf5_location'])
                pattern_names = [pattern['name'] for pattern
                                 in self.description['jobs']['pattern']]
                if name in pattern_names:
                    # They are written into the HDF5 file by Jterator himself
                    # and are therefore not created in the pipeline.
                    # So there is no need to check them here.
                    continue
                if handles['input'][input_arg]['hdf5_location'] not in outputs:
                    raise JteratorError('Input "%s" of module "%s" is not '
                                        'created upstream in the pipeline.' %
                                        (input_arg, module['name']))
        print('jt - Input/output check successful!')
