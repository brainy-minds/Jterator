import os
import json
from jterator.error import JteratorError
from jterator.module import Module


PIPE_FILENAMES = ['JteratorPipe.json', 'jt.pipe']


class JteratorRunner(object):

    def __init__(self, pipeline_folder_path):
        self.pipeline_folder_path = pipeline_folder_path
        self.modules = list()
        self.__description = None
        self.pipeline_filepath = None

    @property
    def logs_path(self):
        return os.path.join(self.pipeline_folder_path, 'logs')

    def locate_pipeline_filepath(self):
        '''Detect filepath to pipeline description if found.'''
        # Where is the pipeline description file?
        if not self.pipeline_filepath is None:
            return
        for pipe_filename in PIPE_FILENAMES:
            pipeline_filepath = os.path.join(self.pipeline_folder_path,
                                             pipe_filename)
            if os.path.exists(pipeline_filepath):
                self.pipeline_filepath = pipeline_filepath
                break
        # Still not found?
        if self.pipeline_filepath is None:
            raise JteratorError('Failed to load pipeline description. '
                                'Make sure to put one of the files "%s"'
                                ' into your pipeline path.' %
                                PIPE_FILENAMES)

    @property
    def description(self):
        if self.__description is None:
            self.locate_pipeline_filepath()
            # Read and parse JSON.
            # TODO: perform expected JSON schema validation.
            description_in_json = open(self.pipeline_filepath).read()
            self.__description = json.loads(description_in_json)
        return self.__description

    def build_pipeline(self):
        '''Build pipeline from JSON description.'''
        for module_description in self.description:
            executable_path = os.path.join(
                self.pipeline_folder_path,
                module_description['module'],
            )
            handles_filepath = os.path.join(
                self.pipeline_folder_path,
                module_description['handles_filepath'],
            )
            if not os.path.exists(executable_path):
                raise JteratorError('Missing module executable: %s' %
                                    executable_path)
            module = Module(
                name=module_description['name'],
                executable_path=executable_path,
                handles_filepath=handles_filepath,
            )
            self.modules.append(module)
        if not self.modules:
            raise JteratorError('Not a single module description was found in:'
                                ' %s' % self.pipeline_filepath)

    def run_pipeline(self):
        '''Run modules one after another, pass handles to each of them'''
        for module in self.modules:
            module.set_error_output(os.path.join(self.logs_path,
                                    '%s.error' % module.name))
            module.set_standard_output(os.path.join(self.logs_path,
                                       '%s.output' % module.name))
            module.run()
