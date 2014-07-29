Jterator
========

Yet another awesome pipeline engine using JSON and HDF5 files for scientific data analysis.

Pipeline.pipe: 
JSON file that serves as descriptor of the pipeline, i.e. provides the details (e.g. input, output) for the modules (functions in different high-level languages) that will be executed one after another (may ultimately be replaced by YAML)

Input.handles:
JSON file that serves as input argument for each module. It provides the location of input and output data within the HDF5 file (see below) and additional information required for execution of the module. There will be n .handles files, where n is the number of modules. The "files" (can also be standard input) will be created by Jterator.py and passed to the call of the modules.

Module.jt:
a function in any of the following languages: Python, Matlab, R. This function receives a string (filename of a the .handles JSON file) as input argument. It reads the content of the JSON file into the environment, loads the required input data from the HDF5 file, does whatever processing, and writes the output data into the HDF5 file.

Data.h5
serves as key-value storage file for input and output data of the modules.
