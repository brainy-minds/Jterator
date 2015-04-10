# Tests #

This directory provides a little test project with a small set of images to process. For each *job*, an image is loaded in the first module of the pipeline and then passed from module to module. Modules are all written in different languages. In each module, data type and dimensionality of the image is printed to standard output as well as a pixel value at a particular index position.

The successful completion of this test gives you the following information:   
* Jterator and all its dependencies were successfully installed. 	
* The core code of the program (`src`) and its APIs (`api`) are working. 	
* YAML syntax of *.pipe* and *.handles* descriptor files is correctly interpreted and translated by each API and data types can be asserted in a language-specific manner. 	
* The pipeline logic works, i.e. information can be shared between modules via HDF5 files. 	
* Data (in particular arrays) are correctly passed through the pipeline. This is not trivial, because dimensions get swapped in HDF5 (column-based vs. row-based) and language-specific libraries handle this differently. In some APIs arrays have to be transposed after loading and before writing in order to be compatible with other APIs. 	
