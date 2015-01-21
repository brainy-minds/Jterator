Jterator
========

[![Build Status](https://travis-ci.org/HackerMD/Jterator.svg?branch=master)](https://travis-ci.org/HackerMD/Jterator)

A minimalistic pipeline engine for scientific computing. It is designed to be flexible, but at the same time handy to work with. Jterator is a command-line tool for Unix systems. It comes without a GUI, but rather makes use of easily readable and modifiable YAML files. Figures can either be saved as PDF files or plotted in the browser using d3 technology.


External libraries
------------------

Jterator depends on the following languages and external libraries:

* Python   
    
    https://www.python.org/downloads/

* Julia (required for Mscript)

    http://julialang.org/downloads/

    To install from source:

    ```bash
    git clone git://github.com/JuliaLang/julia.git ~/julia
    cd ~/julia
    git checkout release-0.3
    make
    ```

* HDF5

    OSX:
    install via homebrew (https://github.com/Homebrew/homebrew-science)

    ```bash
    brew tap homebrew/science; brew install hdf5
    ```

    Linux:

    ```bash
    apt-get -u install hdf5-tools
    ```

* Plotly (optional)    
    
    https://plot.ly/api/


APIs
----

Jterator is written in Python, but can pipe custom code in different languages. APIs for input/output handling are currently implemented in the following languages: 
* Python
* R
* Julia
* Matlab

Language specific package dependencies: 
* Python 
    - *YAML*    
    - *h5py*    
* R     
    - *yaml*    
    - *rhdf5*   
* Julia     
    - *YAML*    
    - *HDF5*    
    - *MATLAB*  
* Matlab (already provided)
    - *mhdf5tools* (includes important extensions!)
    - *yamlmatlab*

The following functions are available for modules in all above listed languages: 

Input/output:      
* **gethandles**: Reading "handles" stream (standard input) from YAML file.
* **readinputargs**: Reading input arguments from HDF5 file using the location specified in "handles".
* **checkinputargs**: Checking input arguments for correct "class" (i.e. type).
* **writeoutputargs**: Writing output arguments to HDF5 file using the location specified in "handles".
* **writedata**: Writing data to HDF5 file.

Tools (not yet implemented):      
* **jtfigure**: Saving figures as PDF or sending it to plotly.

Ultimately, we will provide the APIs via packages for each language (see TODO). For now, you have to add the path to the API for each language: 
- Python
    Include the following line in your *.bash_profile* file:    
    ```bash
    export PYTHONPATH=$HOME/jterator/src/python
    ```
- R
    Include the following line in your *.Rprofile* file:    
    ```R
    source(file.path(Sys.getenv("HOME"), "jterator/src/r/jterator/api/io.R"))
    ```
- Julia
    Include the following line in your *.juliarc.jl* file:  
    ```Julia
    include(joinpath(homedir(), "jterator/src/julia/jterator/api/io.jl"))
    ```
- Matlab
    Include the following line in your *startup.m*:     
    ```Matlab
    addpath(genpath(fullpath(getenv('HOME'),'jterator/src/matlab')))
    ```


Pipeline
========


Modules
-------

Think of your pipeline as a sequence of connected modules (a linked list). 
The sequence and structure of your pipeline is defined in a YAML pipeline descriptor file. The input/output settings for each module are provided by additional YAML handles descriptor files. Each module represents a program that reads YAML from an STDIN file descriptor. Outputs are stored in two separate HDF5 files: measurement data, which will be kept, and temporary pipeline data, which will be discarded.


Project layout 
--------------

Each pipeline has the following layout on the disk:

* **handles** folder contains all the YAML handles files, they are passed as STDIN to *modules*.
* **modules** folder contains all the executable code for programs.
* **logs** folder contains all the output from STDOUT and STERR streams, obtained for each executable that has been executed.
* **data** folder contains all the data output in form of HDF5 files. These data are shared between modules. 
* **figures** folder contains the PDFs of the plots (optional).
* **subfunctions** folder contains additional executable code, which is called by modules.

Jterator allows only very simplistic type of work-flow -  *pipeline* (somewhat similar to a UNIX-world pipeline). Description of such work-flow must be put sibling to the folder structure described about, i.e. inside the Jterator project folder. Recognizable file name must be **'[ProjectName].pipe'**. Description is a YAML format. 


Pipeline descriptor file
------------------------

Describe your pipeline in the .pipe (YAML) descriptor file:

```yaml
Project:

    name: myJteratorProject
    description:

Jobs:

    folder: path/to/myFolder
    pattern: 
        - name: myImage
          expression: .*\.png
        - name: myOtherImage
          expression: .*\.tiff?

Pipeline:

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
Note that the value for the "interpreter" key can be either a full path to the interpreter program (e.g. /usr/bin/python) or a command that can be interpreted by /usr/bin/env (e.g. python).
Also note that the working directory is the jterator project folder. You can provide either a full path to modules and handles files or a path relative to the project folder.


Handles descriptor files
------------------------

Describe your modules in the .handles (YAML) descriptor files (Python example):

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
The value of the key "hdf5_filename" can be left empty or set to 'None'.
It will be filled in by Jterator. The program generates a temporary file
and writes its filename into the handles descriptor file in order to make it available to the modules. 
Note that the temporary file will currently not get killed when an error occurs. This is implemented in this way to allow debugging of the module that broke. Make sure to clean up the temporary files manually.    
There are two different types of input arguments:
* *hdf5_location* is an argument that has to be produced upstream in the pipeline by another module, which saved it into the HDF5 file.
* *parameter* is an argument that is used to control the behavior of the module.   
Note that you can provide the optional "class" key, which asserts the datatype
of the passed argument. It is language specific, e.g. 'float64' in Python, 'double' in Matlab, 'Array{Float64,2}' in Julia or 'array' in R.


Getting started
---------------

To *download* Jterator clone this repository:

```bash
git clone git@github.com:HackerMD/Jterator.git ~/jterator
```

To *use* the Jterator command line interface, add the jterator directory to your executable path:

```bash
export PATH=$PATH:~/jterator/src/python
```
To add the executable path permanently, include this command in your .bash_profile file.
    
Alternatively, you can install Jterator locally:
```bash
cd ~/jterator
pip install -e .
```

To *use* Mscript - a custom tool based on the Julia Matlab interface (https://github.com/JuliaLang/MATLAB.jl) for transforming Matlab scripts into real executables - create a softlink in a directory on your PATH (e.g. /usr/bin):

```bash
cd /usr/bin
sudo ln -s ~/jterator/src/julia/mscript.jl Mscript
```

To *create* a new jterator project, do:

```bash
jt create [/my/jterator/project/folder] --skel [/my/repository/with/jterator/skeleton]
```

This will create your project folder, which will then already have the correct folder layout and will contain skeletons for YAML descriptor files and modules. It will also provide you with the required APIs.
Now you will have to place your custom code into the module skeletons and define the pipeline in the .pipe file as well as input/output arguments in the corresponding .handles files. And shabam! you are ready to go...

To *check* your existing jterator project (YAML descriptor files), do:

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
=====

Package management for external dependencies and APIs in different languages.  
