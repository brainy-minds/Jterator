Jterator
========

Yet another awesome pipeline engine using JSON and HDF5 files for scientific data analysis.

Pipeline.JSON 
serves as descriptor file for the pipeline, i.e. the details (e.g. input, output) for the modules (functions in different languages) that will be processes one after another (may ultimately be replaced by JAML)

Module_i.JSON
serves as input file for each module. There will be n Module_i.JSON files (i=1:n), where n is the number of modules. The files will be created by Jterator.py and passed to the call of the modules.

Handles.h5
serves as "handles" file for handling input and output of the modules. The information required by modules will thus not be kept in memory. In addition, it allows chaining different languages.
