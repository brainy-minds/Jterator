Jterator
========

[![Build Status](https://travis-ci.org/HackerMD/Jterator.svg?branch=master)](https://travis-ci.org/HackerMD/Jterator)

A minimalistic pipeline engine for scientific computing. It is designed to be flexible, but at the same time handy to work with. Jterator is a command-line tool for Unix systems. It comes without a GUI, but rather makes use of easily readable and modifiable YAML files. Figures can either be saved as PDF files or displayed in the browser using d3 technology.


External libraries
------------------

Jterator depends on the following languages and external libraries:

* **Python**   
    
    https://www.python.org/downloads/   

    *Jterator* is written in python. For a full list of python package dependencies see setup.py.   

    Note for Brutus users:      
    Import Python module (use 2.7.2)
    ```
    module load python/2.7.2
    ```

* **HDF5**

    OSX:
    install via homebrew (https://github.com/Homebrew/homebrew-science)

    ```bash
    brew tap homebrew/science; brew install hdf5
    ```

    Linux:

    ```bash
    apt-get -u install hdf5-tools
    ```

    Note for Brutus users:      
    Import HDF5 module
    ```
    module load hdf5
    ```

optional
--------

* **Julia** (required for Mscript, i.e. execution of Matlab modules)

    http://julialang.org/downloads/

    To install from source:

    ```bash
    git clone git://github.com/JuliaLang/julia.git ~/julia
    cd ~/julia
    git checkout release-0.3
    make
    ```

    Note for Brutus users:  
    You need to install Julia in your home directory.
    To this end, create a 'Make.user' file and add the following lines 
    ```
    OPENBLAS_NO_AVX=1
    OPENBLAS_NO_AVX2=1
    OPENBLAS_DYNAMIC_ARCH=1
    ```
* **R**     
    
    http://www.r-project.org

    Note for Brutus users:  
    Import R module (use version 3.1.2) 
    ```
    module load new openblas/0.2.8_seq r/3.1.2
    ```


APIs
----

Jterator is written in Python, but can pipe custom code in different languages. APIs for input/output handling are currently implemented in the following languages: 
* Python
* Julia
* Matlab
* R

APIs depend on the following packages:   
* Python 
    - *PyYAML*    
    - *h5py*  
    - *matplotlib*
    - *mpld3*   
    Note for Brutus users:  
    Install packages as follows 
    ```
    pip install --user [package]
    ```      
* Julia     
    - *YAML*    
    - *HDF5*    
        Note for Brutus users:      
        Modify line 48 in BinDeps.jl (put :wget at first position)    
        ```
        checkcmd in (:wget, :curl, :fetch)
        ```
    - *MATLAB*  
    - *PyCall*
    - *PyPlot*
* Matlab (already provided)
    - *mhdf5tools* (includes important extensions!)
    - *yamlmatlab*  
* R     
    - *yaml*    
    - *rhdf5*  

The following functions are available for modules in all above listed languages: 

Input/output:      
* **gethandles**: Reading "handles" stream (standard input) from YAML file.
* **readinputargs**: Reading input arguments from HDF5 file using the location specified in "handles".
* **checkinputargs**: Checking input arguments for correct "class" (i.e. type).
* **writeoutputargs**: Writing output arguments to HDF5 file using the location specified in "handles".
* **writedata**: Writing data to HDF5 file.     
* **figure2browser**: Displaying d3 figures in the browser (so far only implemented for Python and Julia).

Ultimately, we will provide the APIs via packages for each language using the language specific platform, such as CRAN, PyPI, etc (see TODO). For now, you have to add the path to the APIs.
To this end, include the following lines in your *.bash_profile* file:   
- Python    

    ```bash
    export PYTHONPATH=$PYTHONPATH:$HOME/jterator/src/python
    ```

- R     

    ```bash
    export R_LIBS=$R_LIBS:$HOME/jterator/src/r/jterator
    ```

- Julia     

    ```bash
    export JULIA_LOAD_PATH=$JULIA_LOAD_PATH:$HOME/jterator/src/julia/jterator
    ```

- Matlab    

    ```bash
    export MATLABPATH=$MATLABPATH:$HOME/jterator/src/matlab
    ```
Now you should be ready to go.   


Pipeline
========

Think of your pipeline as a sequence of connected modules (a linked list). 
The sequence and structure of your pipeline is defined in a YAML pipeline descriptor file. The input/output settings for each module are provided by additional YAML handles descriptor files. Each module represents a program that reads YAML from standard input (STDIN) and stores outputs in HDF5 files.
There are two different HDF5 files:             
    - .data file for measurement data: located in your project directory      
    - .tmp file for temporary pipeline data: located in a temporary directory  
Thereby, measurement data, which you would ultimately like to obtain, and pipeline data, which are only passed form module to module, are completely separated from each other. Note that the temporary pipeline file and with it all its data will be deleted after successful completion of the pipeline! However, the file will remain in case of an error that breaks your pipeline, so that you are able to debug the corresponding module without having to re-run the whole pipeline allover again. The file will however get deleted automatically once you shut down or restart your computer.     


Project layout 
--------------

Each project folder has the following layout on the disk:

* **handles** folder contains all the YAML handles files, they are passed as STDIN stream to *modules*.
* **modules** folder contains all the executable code for programs.     
* **subfunctions** folder contains additional executable code (e.g. custom packages), which is required by modules.      
These folders are simply suggestions and will be created in case you call 'jt create' (see below). The corresponding files also don't have to be within your project directory. Feel free to put them wherever you like, you can specify the full path to these files in the pipeline descriptor file. Note that it's your responsibility, however, to ensure that the '*subfunctions*' directory is on your path!

* **logs** folder contains all the output from STDOUT and STERR streams, obtained for each executable that has been executed.
* **data** folder contains all the data output in form of HDF5 files.   
* **figures** folder contains PDF or HTML files of figures saved by modules.   
These folders are created by *Jterator* in the project directory once you run the pipeline.     

So far, *Jterator* allows only very simplistic type of work-flow -  *pipeline* (somewhat similar to a UNIX-world pipeline). Description of such work-flow must be put sibling to the folder structure described about, i.e. inside the project folder. Recognizable file name must be **'[ProjectName].pipe'**. Description is a YAML format. 


Pipeline descriptor file
------------------------

Describe your pipeline in the .pipe (YAML) descriptor file:

```yaml
project:

    name: myJteratorProject
    description: this is what this project is about

jobs:

    folder: path/to/myFolder
    pattern: 
        - name: myImage
          expression: .*\.png
        - name: myOtherImage
          expression: .*\.tiff?

pipeline:

    -   name: myModule1
        module: modules/myModule1.py
        handles: handles/myModule1.handles
        interpreter: /usr/bin/python

    -   name: myModule2
        module: modules/myModule2.R
        handles: handles/myModule2.handles
        interpreter: Rscript

    -   name: myModule3
        module: modules/myModule3.m
        handles: handles/myModule3.handles
        interpreter: Mscript

    -   name: myModule4
        module: modules/myModule4.jl
        handles: handles/myModule4.handles
        interpreter: julia
```
Note that the value for the **'interpreter'** key can be either a full path to the interpreter program (e.g. /usr/bin/python) or a command that can be interpreted by /usr/bin/env (e.g. python). 
Also note that the working directory is by default the project folder. You can provide either a full path to modules and handles files or a path relative to the project folder.    
The names of the **'jobs'** will be written into the temporary pipeline data HDF5 file in order to make them available for modules.     


Handles descriptor files
------------------------

Describe your modules in the .handles (YAML) descriptor files:  
Python example:          

```yaml
hdf5_filename: None

input:

    StringExample:
        parameter: myString
        class: str

    IntegerExample:
        parameter: 1
        class: int

    Hdf5InputExample:
        hdf5_location: /myModule/InputDataset
        class: ndarray

    ListExample:
        parameter: ["myString1", "myString2", "myString3"]
        class: list

    BoolExample:
        parameter: Yes
        class: bool

output:

    Hdf5OutputExample:
        hdf5_location: /myModule/OutputDataset
        class: float64
```
The value of the key **'hdf5_filename'** can be left empty or set to 'None'.
It will be filled in by *Jterator*. The program generates a temporary file
and adds its filename into the handles descriptor YAML string in order to make it available to the modules. If you want to debug a module, you have to fill in the filename manually!
Note that the temporary file will currently not get killed when an error occurs to allow debugging of the module that broke. The temporary directory will be cleaned automatically once you shut down your computer.     
There are two different types of input arguments:
* **'hdf5_location'** is an argument that has to be produced upstream in the pipeline by another module, which saved the corresponding data into the specified location in the HDF5 file.   
* **'parameter'** is an argument that is used to control the behavior of the module. It is module-specific and hence independent of other modules.    
Note that you can provide the optional **'class'** key, which asserts the datatype of the passed argument. It is language specific, e.g. 'float64' in Python, 'double' in Matlab, 'Array{Float64,2}' in Julia or 'array' in R.


Modules
-------

The Jterator APIs are written in way that enables more or less the same syntax in each language.

Python example:     

```python
from jterator.api import *
import os
import sys
import re


mfilename = re.search('(.*).py', os.path.basename(__file__)).group(1)

###############################################################################
## jterator input

print('jt - %s:' % mfilename)

### standard input
handles_stream = sys.stdin

### retrieve handles from .YAML files
handles = gethandles(handles_stream)

### read input arguments from .HDF5 files
input_args = readinputargs(handles)

### check whether input arguments are valid
input_args = checkinputargs(input_args)

###############################################################################


####################
## input handling ##
####################


################
## processing ##
################


#####################
## display results ##
#####################


####################
## prepare output ##
####################

data = dict()

output_args = dict()


###############################################################################
## jterator output

### write measurement data to HDF5
writedata(handles, data)

### write temporary pipeline data to HDF5
writeoutputargs(handles, output_args)

###############################################################################
```

Matlab example:     

```matlab
import jterator.*;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% jterator input

fprintf(sprintf('jt - %s:\n', mfilename));

%%% read standard input
handles_stream = input_stream; % input_stream is provided by Mscript!

%%% change current working directory
cd(currentDirectory)

%%% retrieve handles from .YAML files
handles = gethandles(handles_stream);

%%% read input arguments from .HDF5 files
input_args = readinputargs(handles);

%%% check whether input arguments are valid
input_args = checkinputargs(input_args);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%
%% input handling %%
%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%
%% processing %%
%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%
%% display results %%
%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%
%% prepare output %%
%%%%%%%%%%%%%%%%%%%%

data = struct();

output_args = struct();


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% jterator output

%%% write measurement data to HDF5
writedata(handles, data)

%%% write temporary pipeline data to HDF5
writeoutputargs(handles, output_args)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
```
Note that Matlab scripts are executed by **Mscript**, a customized Julia-based Matlab engine, which forwards the standard input stream and the current working directory to the Matlab session.     

Getting started
---------------

To *download* Jterator clone this repository:

```bash
git clone git@github.com:HackerMD/Jterator.git ~/jterator
```

To *install* the Jterator command line interface, do
```bash
cd ~/jterator
pip install -e .
```

Alternatively, you can add the Jterator directory to your executable path:

```bash
export PATH=$PATH:~/jterator/src/python
```
To add the executable path permanently, include this command in your .bash_profile file.
    

To *use* Mscript - a custom tool based on the Julia Matlab interface (https://github.com/JuliaLang/MATLAB.jl) in order to transform Matlab scripts into real executables - create a softlink in a directory on your PATH (e.g. /usr/bin):

```bash
cd /usr/bin
sudo ln -s ~/jterator/src/julia/mscript.jl Mscript
```

To *create* a new Jterator project, do:

```bash
jt create [/my/new/project/folder] --skel [/repository/containing/jterator/skeleton]
```

This will create your project folder and include skeletons for YAML descriptor files and modules.
Now you can place your custom code into the module skeletons and define the pipeline in the .pipe file as well as input/output arguments in the corresponding .handles files. And shabam! you are ready to go...

To *check* your existing project (YAML descriptor files), do:

```bash
jt check [/my/jterator/project/folder]
```

To *run* your pipeline in iterative model, do:

```bash
jt run [/my/jterator/project/folder]
```

To create a *joblist* for parallel computing, do:

```bash
jt joblist [/my/jterator/project/folder]
```

To *run* individual jobs (parallel mode), do:

```bash
jt run [/my/jterator/project/folder] --job [jobID]
```

To *run* a module individually for debugging purposes, do:

```bash
cat [handles_name] | [interpreter] [modules_name]
```
Example for a python module:
```bash
cat handles/myModule.handles | python modules/myModule.py
```
Note that this command works only after you have provided the correct value for the "hdf5_filename" key in the .handles file. The filename of the temporary HDF5 file is printed by *Jterator* into standard output.
There are some issues with debugging (e.g. in python) because 'cat' keeps the standard input blocked. Working on a solution...


Developing Jterator
===================

Modules can be written in any programming language that provides libraries for for *YAML* and *HDF5* file formats.
You are welcome to further extent the list of languages by writing additional APIs.


Nose tests
----------

We use nose framework to achieve code coverage with unit tests. In order to run tests, do

```bash
cd tests && nosetests
```

To do
-----

Package management for external dependencies and APIs in different languages. 

