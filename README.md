Jterator
========

A minimalistic pipeline engine with motivation to be flexible, but uncomplicated enough, so that no GUI is required to work with it.

* use simple format like JSON for basic parametrization whenever possible
** don't be afraid to keep your input settings on the disk
* for performance heavy IO use HDF5 
* used scientific data analysis.
* UNIX pipeline is a one great idea, but it is mostly restricted to text processing

Modules
-------


Think of your pipeline as a sequence of connected modules (a linked list). Each module is a program that get and reads JSON from on STDIN file descriptor.
Such JSON contains all the input settings required by the module.

---

Pipeline.pipe: 
JSON file that serves as descriptor of the pipeline, i.e. provides the details (e.g. input, output) for the modules (functions in different high-level languages) that will be executed one after another (may ultimately be replaced by YAML)

Input.handles:
JSON file that serves as input argument for each module. It provides the location of input and output data within the HDF5 file (see below) and additional information required for execution of the module. There will be n .handles files, where n is the number of modules. The "files" (can also be standard input) will be created by Jterator.py and passed to the call of the modules.

Module.jt:
an executable file (function) in any of the following languages: Python, Matlab, R. This function receives a string (filename of a the .handles JSON file) as input argument. It reads the content of the JSON file into the environment, loads the required input data from the HDF5 file, does whatever processing, and writes the output data into the HDF5 file.

Data.h5
serves as key-value storage file for input and output data of the modules.
