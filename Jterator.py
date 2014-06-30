#!/usr/local/bin/python
import os
import glob
import h5py as h5
import json
from jterator.utils import invoke


PATH_NAME = '/Users/Markus/Documents/Markus/Jterator/ExampleProject'


def JPipe_read(PATH_NAME):

	# make sure that path exists
	if not (os.path.exists(PATH_NAME)):
			raise IOError('Error: directory %s does not exist' % PATH_NAME)

	# look for JSON file and load content
	json_filename = glob.glob('%s/JPipe*.json' % PATH_NAME)
	if len(json_filename)>1: # there should be only one such file
			raise IOError('Error: more than one "JPipe*.json" file found in directory %s' % PATH_NAME)
	elif not json_filename:
			raise IOError('Error: no "JPipe*.json" file found in directory %s' % PATH_NAME)

	json_filename = json_filename[0]
	json_content = json.load(open(json_filename))

	# read "Pipeline"
	pipeline = json_content['Pipeline']

	# read "Filenames"
	function_names = dict()
	for module in pipeline:
		if not (os.path.isfile(pipeline[module]['Filename'])):
			raise IOError('Error: file %s does not exist. Please check "Pipeline" in %s.' %(pipeline[module]['Filename'],json_filename))
		function_names[module] = pipeline[module]['Filename']

	# read "Input" and "Output"
	input_args = dict()
	output_args = dict()
	for module in pipeline:
		input_args[module] = pipeline[module]['Input']
		output_args[module] = pipeline[module]['Output']

	return function_names
	return input_args
	return output_args



def JPipe_check(pipeline,input_args,output_args):

	# make sure modul names are identical between "Pipeline", "Input" and "Output"
	if not len(function_names)==len(input_args)==len(output_args):
		raise IOError('Error: Modules are not specified correctly. Please check "Pipeline" for "Filename", "Input" and "Output" keys in %s.' %(pipeline[module],json_filename))

	# make sure inputs are created upstream of their use in the pipeline
	for i in xrange(len(sorted(input_args.values()))):
		for arg in sorted(input_args.values())[i]:
			if not arg in sum(sorted(output_args.values())[0:i+1],[]):
				raise IOError('Error: Input argument %s needs to be created before its use in module #%d. Please check "Pipeline" for "Input" and "Output" keys in %s.' %(arg,i,json_filename))



def JHandles_create(PATH_NAME):

	# create hdf5 file
	hdf5_filename = '%s/JHandles_%s.h5' %(PATH_NAME,os.path.basename(PATH_NAME))
	hdf5_file = h5.File(hdf5_filename,'w-')

	# default image directory
	hdf5_file.create_dataset('/Pipeline/defaultImageDirectory', '%s/TIFF' % PATH_NAME, dtype=h5.special_dtype(vlen=str))
	# write as string dataset: http://docs.h5py.org/en/latest/strings.html

	return hdf5_filename
	return hdf5_file



def JModules_create(function_names,input_args):

	# create shell commands
	commands = dict()
	for module in function_names:
		# to do:
		# 	- variable input (multiple input arguments) => json file
		#		-> 1st argument: hdf5_filename
		#		-> further arguments:
		#				- locations in hdf5 file for reading module input
		#				- locations in hdf5 file for writing module output
		# 	- parameters specified in json file
		# 	- create log files
		if function_names[module][-2:] == '.m':
			commands[module] = 'matlab -nodisplay -r "%s(%s); exit"' %(function_names[module][:-3],input_args[module])
		elif function_names[module][-2:] == '.R':
			commands[module] =  'R CMD BATCH -%s %s' %(input_args[module],function_names[module]) # use commandArgs() in R
		elif function_names[module][-3:] == '.py':
			#commands[module] = 'python -c"%(function_name)s(%(function_args)s)"' % {
			commands[module] = 'python -c"%(function_name)s()"' % {
				'function_name': function_names[module],
				#'function_args': input_args[module])
			}

	return commands



def JPipe_run(function_names,input_args,output_args,commands):

	# could all be done via fancy indexing:
	#  - in the "PreCluster" step we pre-allocate the dataset
	#  - in the "CPCluster" step each BATCH then writes its output into a defined position in the same dataset
	#  - no data fusion step required!

	hdf5_content = h5.File(hdf5_filename,'r')

	for module in function_names:

		# make sure input exists
		for input_arg in input_args[module]:
			if not input_arg in hdf5_content:
				raise IOError('Error: Input argument for module 1 "%s" does not exist in %s.' %(input_arg,hdf5_filename))

		# run module in command line
		##os.system(commands[module])
		json_input = input_args[module]
		#JSON = '{"foo": "bar"}'
		output = invoke(commands[module], _in=json_input)

		# are there any errors? -> log file?

		# # wait for output to be created by function
		# while all( output_arg not in hdf5_content for output_arg in output_args[module] ):
		# 		time.sleep(60) # check for output every minute
