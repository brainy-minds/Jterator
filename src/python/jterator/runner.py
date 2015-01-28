import os
import glob
import re
import yaml
import h5py
import numpy as np
import tempfile
from jterator.error import JteratorError
from jterator.checker import JteratorCheck
from jterator.module import Module

# from IPython.core.debugger import Tracer


class JteratorRunner(object):
    '''
    Main component for running a Jterator pipeline.
    '''

    def __init__(self, pipeline_folder_path, logging_level):
        self.logging_level = logging_level
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
        logs_folder = os.path.join(self.pipeline_folder_path, 'logs')
        if not os.path.exists(logs_folder):
            os.mkdir(logs_folder)
        return logs_folder

    def locate_pipe_file(self):
        '''
        Get full path to pipeline descriptor file.
        '''
        # Already found.
        if self.pipeline_filename is not None:
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
        Create temporary file and return its filename.
        '''
        if self.tmp_filename is None:
            # Get absolute path to temporary directory ($TMPDIR)
            tmp_directory = tempfile.gettempdir()
            tmp_filename = os.path.join(tmp_directory, '%s.tmp' %
                                        self.description['project']['name'])
            self.tmp_filename = tmp_filename
            print('jt - Temporary pipeline data is stored in HDF5 file "%s"'
                  % self.tmp_filename)

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
                            handles=handles_path,
                            interpreter=interpreter_path,
                            tmp_filename=self.tmp_filename,
                            logging_level=self.logging_level)
            self.modules.append(module)
        if not self.modules:
            raise JteratorError('No module description was found in:'
                                ' %s' % self.pipeline_filename)

    def create_job_list(self):
        '''
        Create a list of jobs over which the program should iterate,
        i.e. process one after another or process in parallel.
        '''
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
        # Save joblist to file (as YAML).
        jobs_file_path = os.path.join(self.pipeline_folder_path,
                                      '%s.jobs' %
                                      self.description['project']['name'])
        self.jobs_file_path = jobs_file_path
        stream = file(jobs_file_path, 'w+')
        yaml.dump(job_list, stream, default_flow_style=False)
        print('jt - Joblist was written to file: "%s".' % jobs_file_path)
        # Double-check that jobID is correctly specified for each job.
        for job_id in job_list:
            if not job_id == job_list[job_id]['jobID']:
                raise JteratorError('"JobID" of job #%d is incorrect. '
                                    'Check joblist file "%s".' %
                                    (job_id, jobs_file_path))

    def get_job_list(self):
        '''
        Get the list of jobs over which the program should iterate,
        i.e. process one after another or process in parallel.
        '''
        jobs_file_path = os.path.join(self.pipeline_folder_path,
                                      '%s.jobs' %
                                      self.description['project']['name'])
        if not os.path.exists(jobs_file_path):
                raise JteratorError('No joblist file found! '
                                    'Call "jt joblist" before "jt run"!')
        job_list = yaml.load(open(jobs_file_path).read())
        self.joblist = job_list

    def create_hdf5_files(self, job):
        '''
        Create HDF5 files for temporary pipeline data and module output.
        '''
        # Create HDF5 file for pipeline data (temporary file).
        # Alternatively, consider using "HDF5 File Image Operations".
        tmp_root = h5py.File(self.tmp_filename, 'w')
        # Write the full path of the processed item into defined location.
        for item in job:
            if isinstance(job[item], str):
                item_path = os.path.join(self.description['jobs']['folder'],
                                         job[item])
                # Only Fixed-length ASCII are compatible (use numpy strings)!!!
                tmp_root.create_dataset(item, data=np.string_(item_path))
            else:
                item_path = job[item]
                tmp_root = h5py.File(self.tmp_filename, 'r+')
                tmp_root.create_dataset(item, data=item_path)
        # Create HDF5 file for measurement data (persistent file).
        output_path = os.path.join(self.pipeline_folder_path, 'data')
        if not os.path.isdir(output_path):
            os.mkdir(output_path)
        # For now, we create one hdf5 file for each job.
        output_filename = os.path.join(output_path, '%s_%.5d.data' %
                                       (self.description['project']['name'],
                                        job['jobID']))
        print('jt - Measurement data is stored in HDF5 file "%s".'
              % output_filename)
        data_root = h5py.File(output_filename, 'w')
        data_root.close()
        # Write name of datafile into the temporary HDF5 file.
        # Only Fixed-length ASCII are compatible (use numpy strings)!!!
        tmp_root.create_dataset('datafile', data=np.string_(output_filename))
        tmp_root.create_dataset('jobid', data=job['jobID'])
        # Close the file (very important!).
        tmp_root.close()

    def run_pipeline(self, job_id):
        '''
        For each iteration, run one module after another (or in parallel) and
        pass their corresponding handles to them.
        '''
        self.init_hdf5_files()
        # Check structure of pipeline and handles description.
        checker = JteratorCheck(self.description, self.tmp_filename)
        checker.check_pipeline()
        checker.check_handles()
        checker.check_pipeline_io()
        # Build the pipeline.
        self.build_pipeline()
        print('jt - Log files are stored in directory "%s"' % self.logs_path)
        if job_id is None:  # iterative mode
            # Create and get joblist.
            self.create_job_list()
            self.get_job_list()
            # Iterate over job items.
            for job in self.joblist.itervalues():
                print('\njt - Running job # %d ...' % job['jobID'])
                # Initialize the pipeline.
                self.create_hdf5_files(job)
                # Run the pipeline.
                for module in self.modules:
                    print('jt - Running module "%s" ...\n' % module.name)
                    module.set_error_output(os.path.join(self.logs_path,
                                            '%s_%.5d.error' % (module.name, job['jobID'])))
                    module.set_standard_output(os.path.join(self.logs_path,
                                               '%s_%.5d.output' % (module.name, job['jobID'])))
                    module.run()
                # Delete temporary pipeline file
                os.remove(self.tmp_filename)
        else:  # parallel mode
            # Get joblist (needs to be pre-created calling 'jt joblist').
            self.get_job_list()
            job = self.joblist[job_id]
            print('\njt - Running job # %d' % job['jobID'])
            # Initialize the pipeline.
            self.create_hdf5_files(job)
            # Run the pipeline.
            for module in self.modules:
                print('jt - Running module "%s" ...\n' % module.name)
                module.set_error_output(os.path.join(self.logs_path,
                                        '%s_%.5d.error' % (module.name, job['jobID'])))
                module.set_standard_output(os.path.join(self.logs_path,
                                           '%s_%.5d.output' % (module.name, job['jobID'])))
                module.run()
            # Delete temporary pipeline file
            os.remove(self.tmp_filename)
