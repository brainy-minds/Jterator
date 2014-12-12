import os
import glob
import re
import yaml
import h5py
from jterator.error import JteratorError
from jterator.checker import JteratorCheck
from jterator.module import Module

from IPython.core.debugger import Tracer


class JteratorRunner(object):

    def __init__(self, pipeline_folder_path):
        self.pipeline_folder_path = os.getcwd()
        self.modules = list()
        self.__description = None
        self.pipeline_filename = None
        self.tmp_filename = None
        self.joblist = None

    @property
    def logs_path(self):
        '''
        Define logs path.
        '''
        return os.path.join(self.pipeline_folder_path, 'logs')

    def locate_pipe_file(self):
        '''
        Get full path to pipeline descriptor file.
        '''
        # Already found.
        if not self.pipeline_filename is None:
            return
        # Find the pipeline description file in project folder.
        pipe_filenames = glob.glob(os.path.join(
                                   self.pipeline_folder_path, "*.pipe"))
        # There should only be one pipeline descriptor file.
        if len(pipe_filenames) > 1:
            raise JteratorError('More than more pipeline descriptor file '
                                'found in project folder: %s.' %
                                self.pipeline_folder_path)
        elif len(pipe_filenames) == 0:
            raise JteratorError('No pipeline descriptor file '
                                'found in project folder: %s.' %
                                self.pipeline_folder_path)
        else:
            self.pipeline_filename = pipe_filenames[0]
        # Still not found?
        if self.pipeline_filename is None:
            raise JteratorError('Failed to load pipeline description. Make '
                                'sure to put it the file into the project '
                                'folder: %s' % self.pipeline_folder_path)

    def read_pipe_file(self, yaml_filepath):
        '''
        Read pipeline descriptor YAML file.
        '''
        yaml_data = open(yaml_filepath).read()
        try:
            return yaml.load(yaml_data)
        except yaml.YAMLError as yaml_error:
            linelabeled_yaml = '\n'.join(['%i: %s' % (index, line)
                                          for index, line
                                          in enumerate(yaml_data.split('\n'))])
            raise JteratorError('YAML description of the pipeline (%s) '
                                'contains an error:\n%s\n%s\n%s' %
                                (self.pipeline_filename, str(yaml_error),
                                 '='*80, linelabeled_yaml))

    @property
    def description(self):
        '''
        Obtain pipeline description from YAML file.
        '''
        if self.__description is None:
            # Detect filepath to pipeline descriptor file.
            self.locate_pipe_file()
            # Read and parse pipeline descriptor file.
            self.__description = self.read_pipe_file(self.pipeline_filename)
        return self.__description

    def init_hdf5_files(self):
        '''
        Determine name of HDF5 files for temporary pipeline data.
        '''
        if self.tmp_filename is None:
            tmp_path = os.path.join(self.pipeline_folder_path, 'tmp')
            if not os.path.isdir(tmp_path):
                os.mkdir(tmp_path)
            tmp_filename = os.path.join(tmp_path, '%s.tmp' %
                                        self.description['project']['name'])
            self.tmp_filename = tmp_filename

    def build_pipeline(self):
        '''
        Build pipeline in modular form.
        '''
        # Interpret module description.
        for module_description in self.description['pipeline']:
            # Get path to module (executable file containing actual code)
            module_path = os.path.join(self.pipeline_folder_path,
                                       module_description['module'])
            # Does module file exist?
            if not os.path.exists(module_path):
                raise JteratorError('Missing module: %s' %
                                    module_path)
            # Is module file executable?
            if not os.access(module_path, os.R_OK):
                raise JteratorError('Module is not executable: %s' %
                                    module_path)
            # Get path to handles (YAML file describing model input/output)
            handles_path = os.path.join(self.pipeline_folder_path,
                                        module_description['handles'])
            # Does handles file exist?
            if not os.path.exists(handles_path):
                raise JteratorError('Missing handles: %s' %
                                    handles_path)
            # Get path to interpreter program.
            interpreter_path = module_description['interpreter']
            # Does interpreter program exist?
            if os.path.isabs(interpreter_path):
                if not os.path.exists(interpreter_path):
                    raise JteratorError('Missing interpreter: %s' %
                                        interpreter_path)
                if not os.access(interpreter_path, os.R_OK):
                    raise JteratorError('Interpreter is not executable: %s' %
                                        interpreter_path)
            # Extract module information from pipeline description.
            module = Module(name=module_description['name'],
                            module=module_path,
                            handles=open(handles_path),
                            interpreter=interpreter_path)
            self.modules.append(module)
        if not self.modules:
            raise JteratorError('No module description was found in:'
                                ' %s' % self.pipeline_filename)

    def create_job_list(self):
        '''
        Create a list of jobs over which the program should iterate,
        i.e. process one after another or process in parallel.
        '''
        if self.joblist is None:
            # Check pipeline description.
            self.init_hdf5_files()
            checker = JteratorCheck(self.description, self.tmp_filename)
            checker.check_pipeline()
            # Create joblist based on pipeline description.
            folder_path = self.description['jobs']['folder']
            folder_content = os.listdir(folder_path)
            folder_content = sorted(folder_content)
            if not os.path.isabs(folder_path):
                folder_path = os.path.join(self.pipeline_folder_path,
                                           folder_path)
            if not os.path.exists(folder_path):
                raise JteratorError('Folder "%s" does not exist. Double-check '
                                    '"jobs" section in your pipeline '
                                    'description: "%s".' %
                                    (folder_path, self.pipeline_filename))
            # Extract files from folder for each pattern.
            iteration_pattern = self.description['jobs']['pattern']
            jobs_per_pattern = dict()
            for pattern in iteration_pattern:
                jobs = [filename for filename in folder_content
                        if re.match(pattern['expression'], filename)]
                if len(jobs) == 0:
                    raise JteratorError('No files found in folder "%s" that match '
                                        'pattern "%s". Double-check "jobs" '
                                        'section in your pipe description: "%s".' %
                                        (folder_path, pattern['expression'],
                                         self.pipeline_filename))
                job_ids = [jobid+1 for jobid in xrange(len(jobs))]
                jobs_per_pattern[pattern['name']] = jobs
                jobs_per_pattern['jobID'] = job_ids
            # Make sure all pattern result in same number of jobs.
            job_number = [len(jobs) for jobs in jobs_per_pattern.itervalues()]
            if not len(set(job_number)) == 1:
                raise JteratorError('The files found in folder "%s" for pattern '
                                    'resulted in different number of jobs.' %
                                    folder_path)
            # Wrap all pattern into one joblist.
            job_list = dict()
            for job_id in jobs_per_pattern['jobID']:
                index = job_id - 1
                job_list[job_id] = dict()
                job_list[job_id]['jobID'] = jobs_per_pattern['jobID'][index]
                for pattern in iteration_pattern:
                    key = pattern['name']
                    job_list[job_id][key] = jobs_per_pattern[key][index]
            self.joblist = job_list
            # Save joblist to file (as YAML).
            jobs_file_path = os.path.join(self.pipeline_folder_path,
                                          '%s.jobs' %
                                          self.description['project']['name'])
            self.jobs_file_path = jobs_file_path
            stream = file(jobs_file_path, 'w+')
            yaml.dump(job_list, stream, default_flow_style=False)
            # Double-check that jobID is correctly specified for each job.
            for job_id in job_list:
                if not job_id == job_list[job_id]['jobID']:
                    raise JteratorError('"JobID" of job #%d is incorrect. '
                                        'Check joblist file "%s".' %
                                        (job_id, jobs_file_path))

    def create_hdf5_files(self, job):
        '''
        Create HDF5 files for temporary pipeline data and module output.
        '''
        # Create HDF5 file for temporary data
        # (for pipeline data; temporary file).
        h5py.File(self.tmp_filename, 'w')
        # Write the full path of the processed item into defined location.
        for item in job:
            if isinstance(job[item], str):
                item_path = os.path.join(self.description['jobs']['folder'],
                                         job[item])
                # dt = h5py.special_dtype(vlen=str)
                # tmp_root.create_dataset(item, data=item_path, dtype=dt)
            else:
                item_path = job[item]
            tmp_root = h5py.File(self.tmp_filename, 'r+')
            tmp_root.create_dataset(item, data=item_path)
        tmp_root.close()
        # Create HDF5 file for measurement data
        # (for pipeline output; persistent file).
        output_path = os.path.join(self.pipeline_folder_path, 'data')
        if not os.path.isdir(output_path):
            os.mkdir(output_path)
        output_filename = os.path.join(output_path, '%s_%s.data' %
                                       (self.description['project']['name'],
                                        item))
        h5py.File(output_filename, 'w')

    def run_pipeline(self, job_id):
        '''
        For each iteration, run one module after another and
        pass their corresponding handles to them.
        '''
        self.init_hdf5_files()
        # Check structure of pipeline and handles description.
        checker = JteratorCheck(self.description, self.tmp_filename)
        checker.check_handles()
        checker.check_pipeline_io()
        # Build the pipeline.
        self.build_pipeline()
        if job_id is None:  # non-parallel mode
            # Create joblist and iterate over job items.
            self.create_job_list()
            for job in self.joblist.itervalues():
                # Initialize the pipeline.
                self.create_hdf5_files(job)
                # Run the pipeline.
                for module in self.modules:
                    module.set_error_output(os.path.join(self.logs_path,
                                            '%s.error' % module.name))
                    module.set_standard_output(os.path.join(self.logs_path,
                                               '%s.output' % module.name))
                    module.run()
                # Kill the temporary file containing the pipeline data.
                os.remove(self.tmp_filename)
        else:  # parallel mode!
            # Make sure joblist file was created.
            if not os.path.exists(self.jobs_file_path):
                raise JteratorError('No joblist file found! '
                                    'Call "jt joblist"!')
            # Initialize the pipeline.
            items = yaml.load(open(self.jobs_file_path).read())
            item = items[job_id]
            item_path = os.path.join(self.description['jobs']['folder'],
                                     item)
            item_path = self.jobs_file_path
            self.create_hdf5_files(item_path)
            # Run the pipeline.
            for module in self.modules:
                module.set_error_output(os.path.join(self.logs_path,
                                        '%s.error' % module.name))
                module.set_standard_output(os.path.join(self.logs_path,
                                           '%s.output' % module.name))
                module.run()
            # Kill the temporary file containing the pipeline data.
            os.remove(self.tmp_filename)
