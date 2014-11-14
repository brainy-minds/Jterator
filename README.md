Jterator
========

[![Build Status](https://travis-ci.org/ewiger/Jterator.svg?branch=master)](https://travis-ci.org/ewiger/Jterator)


A minimalistic pipeline engine for scientific computing. It is designed to be flexible, but at the same time handy to work with. Jterator is a command-line tool for Unix systems. It comes without a GUI, but rather makes use of easily readable and modifiable YAML files. Figures can either be saved as PDF files or plotted in the browser using d3 technology.


Languages
---------

Jterator can pipe custom code in different languages. APIs for input/output handling are currently implemented in the following languages: 
* Matlab
* R
* Python
* Julia


External libraries
------------------

* HDF5

OSX:
install via homebrew (https://github.com/Homebrew/homebrew-science)

'''bash
brew tap homebrew/science; brew install hdf5
'''

Linux:

'''bash
apt-get -u install hdf5-tools
'''

Pipeline
========

Modules
-------

Think of your pipeline as a sequence of connected modules (a linked list). 
The sequence and structure of your pipeline is defined in a YAML pipeline descriptor file. The input/output settings for each module are provided by additional YAML handles descriptor files. Each module represents a program that reads YAML from an STDIN file descriptor. Outputs are stored in two separate HDF5 files: measurement data, which will be kept, and temporary pipeline data, which will be ultimately discarded.


Project layout 
--------------

Each pipeline has the following layout on the disk:

* **handles** folder contains all the YAML handles files, they are passed as STDIN to *modules*.
* **modules** folder contains all the executable plus code for programs.
* **logs** folder contains all the output from STDOU and STERR streams, obtained for each executable that has been executed.
* **data** folder contains all the data output in form of HDF5 files. These data are shared between modules. 
* **tmp** folder contains the temporary pipeline data that is shared between modules. These files are killed after successful completion of the pipeline.
* **figures** folder contains the PDFs of the plots (optional).

Jterator allows only very simplistic type of workflow -  *pipeline* (somewhat similar to a UNIX-world pipeline). Description of such workflow must be put sibling to the folder structure described about, i.e. inside the Jterator pipeline (project) folder. Recognizable file name must be one of **'[ProjectName].pipe'**. Description is a YAML format. 


Getting started
---------------

To *download* Jterator clone this repository:

```bash
git clone git@github.com:HackerMD/Jterator.git
```

To *compile* Mscript - a custom tool for transforming Matlab scripts into real executables -, do (not yet implemented):

```bash
cd your/copy/of/Jterator/repo/Mscript make
```

To *initialize* a project, do (not yet implemented):

```bash
jt init /my/jterator/pipeline/folder
```

This will create your project folder, which will then already have the correct folder layout and will contain skeletons for YAML descriptor files and modules. It will also provide you with the required APIs.
Now you will have to place your custom code into the module skeletons and define the pipeline in the .pipe file as well as input/output arguments in the corresponding .handles files. Shabam! You are ready to go...

To *run* your pipeline, do:

```bash
cd /my/jterator/pipeline/folder && jt run
```



Developing Jterator
===================

Modules can be written in virtually any programming language as long as such language can provide tools for working with *YAML* and *HDF5* data formats.
You are welcome to further extent the list of languages by writing additional APIs.


Nose tests
----------

We use nose framework to achieve code coverage with unit tests. In order to run tests, do

```bash
cd tests && nosetests
```

To do
=====

Package management for APIs in different languages.
