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

Pipeline.JSON 
serves as descriptor file for the pipeline, i.e. the details (e.g. input, output) for the modules (functions in different languages) that will be processes one after another (may ultimately be replaced by JAML)

Module_i.JSON
serves as input file for each module. There will be n Module_i.JSON files (i=1:n), where n is the number of modules. The files will be created by Jterator.py and passed to the call of the modules.

Handles.h5
serves as "handles" file for handling input and output of the modules. The information required by modules will thus not be kept in memory. In addition, it allows chaining different languages.
