# Jterator #

[![Build Status](https://travis-ci.org/HackerMD/Jterator.svg?branch=master)](https://travis-ci.org/HackerMD/Jterator)

A minimalistic pipeline engine for scientific computing. It is designed to be flexible and easily customizable, while being at the same time handy to work with. Jterator is a command-line tool for Unix systems. The program itself is written in Python, but it can process code in different languages. It comes without a GUI, but rather makes use of easily readable and modifiable YAML files to define projects and pipeline logic. Figures can be visualized in a web browser using d3 technology. This approach keeps the list of dependencies short and makes it easy to develop and test new workflows.


## Dependencies ##

Jterator depends on the following languages and external libraries:

* **Python**      

    *Jterator* is written in python. For a full list of python package dependencies see setup.py.   

    Note for Brutus users:      
    Import Python module (use 2.7.2)
        ```
        module load python/2.7.2
        ```


* **HDF5**

    OSX:
    ```{bash}
    brew tap homebrew/science; brew install hdf5
    ```

    Linux:
    ```{bash}
    apt-get -u install hdf5-tools
    ```

    Note for Brutus users:      
    Import HDF5 module
        ```
        module load hdf5
        ```


### optional ###

* **Julia** (required for Mscript in order to execute Matlab modules)

    Download [here](http://julialang.org/downloads/) or install form source:

    ```{bash}
    git clone git://github.com/JuliaLang/julia.git ~/julia
    cd ~/julia
    git checkout release-0.3
    make
    ```

    Note for Brutus users:  
    You need to install Julia in your home directory.
    To this end, create a 'Make.user' file and add the following lines      
    ```{bash}
    OPENBLAS_NO_AVX=1
    OPENBLAS_NO_AVX2=1
    OPENBLAS_DYNAMIC_ARCH=1
    ```

* **R**     
    
    Download [here](http://www.r-project.org).

    Note for Brutus users:  
    Import R module (use version 3.1.2) 
        ```
        module load new openblas/0.2.8_seq r/3.1.2
        ```


## APIs ##

Jterator is written in Python, but can pipe custom code in different languages. APIs for input/output handling are currently implemented in the following languages: 
* Python
* Julia
* Matlab
* R

The code can be found in `api`.

APIs depend on the following packages:   
* Python 
    - *PyYAML*      

        ```{bash}
        pip install PyYaml
        ``` 

    - *h5py*  

        ```{bash}
        pip install h5py
        ```     

    Note for Brutus users:  
    Install packages as follows 
        ```
        pip install --user [package]
        ```      
* Julia     
    - *YAML*    

        ```{julia}
        Pkg.add("YAML")
        ```

    - *HDF5*  

        ```{julia}
        Pkg.add("HDF5")
        ```  

        Note for Brutus users:      
        Modify line 48 in BinDeps.jl (put :wget at first position)        
            ```
            checkcmd in (:wget, :curl, :fetch)
            ```     

    Mscript additionally requires   
    - *MATLAB*  

        ```{julia}
        Pkg.add("MATLAB")
        ```
* Matlab    
    - *yamlmatlab*
    - *mhdf5tools*        
    These packages are already provided and include important extensions to the original versions.
* R     
    - *yaml*   

        ```{R}
        install.packages("yaml")
        ```

    - *rhdf5*  

        ```{R}
        source("http://bioconductor.org/biocLite.R")
        biocLite("rhdf5")
        ```


### Functions ###

The following functions are available for modules in all above listed languages: 

Input/output:      
* **gethandles**: Reading "handles" stream (standard input) from YAML file.
* **readinputargs**: Reading input arguments from HDF5 file using the location specified in "handles".
* **checkinputargs**: Checking input arguments for correct data type.
* **writeoutputargs**: Writing output arguments to HDF5 file using the location specified in "handles".
* **writedata**: Writing data to HDF5 file.     
* **figure2browser**: Displaying d3 figures in the browser (so far only implemented for Python).

Ultimately, we will provide the APIs via packages for each language using the language specific platform, such as CRAN, PyPI, etc (see TODO). For now, you have to add the path to the APIs.
To this end, include the following lines in your *.bash_profile* file:   
- Python    

    ```{bash}
    export PYTHONPATH=$PYTHONPATH:$HOME/jterator/api/python
    ```

- Julia     

    ```{bash}
    export JULIA_LOAD_PATH=$JULIA_LOAD_PATH:$HOME/jterator/api/julia/jtapi
    ```

- Matlab    

    ```{bash}
    export MATLABPATH=$MATLABPATH:$HOME/jterator/src/matlab
    ```

- R     

    ```{bash}
    export R_LIBS=$R_LIBS:$HOME/jterator/api/r/jtapi
    ```

Now you should be ready to go...  


## Pipeline ##


Think of your pipeline as a sequence of connected modules (a linked list). 
The sequence and structure of your pipeline is defined in a YAML **pipeline descriptor file**. The input/output settings for each module are provided by additional YAML **handles descriptor files**.

Each module represents a program that reads YAML from standard input (STDIN) and stores output in HDF5 files.
There are two different HDF5 files that handle different kind of data:    
    - *.data* file for **measurement data**: located in your project directory      
    - *.tmp* file for **temporary pipeline data**: located in a temporary directory  
Measurement data represent data that you would ultimately like to obtain from your analysis. Pipeline data on the other hand are only passed form module to module. **Note that the temporary pipeline file and all its data will be deleted after successful completion of the pipeline!** The file will remain in case of an error that breaks your pipeline, however, so that you are able to debug the corresponding module without having to re-run the whole pipeline allover again. But the file will ultimately get deleted automatically once you shut down or restart your computer.     


### Project layout  ###

Each project folder has the following layout on disk:

* **handles** folder contains all the YAML handles files, they are passed as STDIN stream to *modules*. This folder has to be created manually. You can do this using the `jt create` command (see below).
* **data** folder contains all the data output in form of HDF5 files. Jterator will automatically create this folder in your project directory.     
* **logs** folder contains all the output from STDOUT and STERR streams, obtained for each executable that has been executed in the pipeline.  Jterator will automatically create this folder in your project directory, but it will remain empty unless you use the `-v` verbosity command.
* **figures** folder contains figure files saved by modules. This folder is optional and you have to create it manually. 
These folders are created by Jterator in the project directory once you run the pipeline.    

The actual code can also reside in the project directory, but you can also put this at any other location. This may be more convenient, because the code is usually reused and independent of the actual project. The layout could be as follows:    

* **modules** folder contains all the executable code for programs.     
* **subfunctions** folder contains additional executable code (e.g. custom packages), which is required by modules.  

This layout is simply a suggestion and will be created in case you call `jt create` (see below). Feel free to put these files wherever you like, you can specify the full path to these files in the pipeline descriptor file. The code in the *subfunctions* folder can be seen as additionally required custom packages that you import in your modules. **Note that it's your responsibility to ensure that 'subfunctions' are on your path!**


### Pipeline descriptor file ###

Jterator allows only very simplistic types of work-flow -  *pipeline* (somewhat similar to a UNIX-world pipeline). Description of such work-flow must be put sibling to the folder structure described about, i.e. inside the project folder. Recognizable file name must be **'[ProjectName].pipe'**. Description is a YAML format. 

Describe your pipeline in the .pipe (YAML) descriptor file:

```{yaml}
project:

    name: myJteratorProject
    libpath: path/to/myRepository

jobs:

    folder: path/to/myFolder
    pattern: 
        - name: myImage
          expression: .*\.png
        - name: myOtherImage
          expression: .*\.tiff?

pipeline:

    -   name: myModule1
        module: "{libpath}/modules/myModule1.py"
        handles: handles/myModule1.handles
        interpreter: /usr/bin/python

    -   name: myModule2
        module: modules/myModule2.R
        handles: handles/myModule2.handles
        interpreter: Rscript

    -   name: myModule3
        module: "{libpath}/modules/myModule3.m"
        handles: handles/myModule3.handles
        interpreter: Mscript

    -   name: myModule4
        module: modules/myModule4.jl
        handles: handles/myModule4.handles
        interpreter: julia
```
Note that the value for the **'interpreter'** key can be either a full path to the interpreter program (e.g. /usr/bin/python) or a command that can be interpreted by /usr/bin/env (e.g. python). 
Also note that the working directory is by default the project folder. You can provide either a full path to modules and handles files or a path relative to the project folder. You can also make use of the `libpath` "variable" within the pipeline descriptor file to specify the location where you keep your module files. Best practice is to have the `handles` folder in you project directory, because the specifications in the handles descriptor files are usually project specific.   
The **'jobs'** section will create a list of jobs with filenames and id for each job that will be stored in a `[ProjectName].jobs` file in YAML format. This information will also automatically be written into the temporary pipeline data HDF5 file in order to make it available for the modules.     


## Handles descriptor files ##

Describe your modules in the .handles (YAML) descriptor files:  
Python example:          

```{yaml}
hdf5_filename: None

input:

    - name: StringExample:
      class: parameter
      value: myString
      type: str

    - name: IntegerExample
      class: parameter
      value: 1
      type: int

    - name: Hdf5InputExample
      class: hdf5_location
      value: /myModule/InputDataset
      type: ndarray

    - name: ListExample
      class: parameter
      value: ["myString1", "myString2", "myString3"]
      type: list

    - BoolExample:
      class: parameter
      value: Yes
      type: bool

output:

    - name: Hdf5OutputExample
      class: hdf5_location
      value: /myModule/OutputDataset
```
The value of the key **'hdf5_filename'** can be left empty or set to 'None'.
This information will be filled in by Jterator automatically; the program generates a temporary hdf5 file and adds its filename into the handles descriptor YAML string in order to make it available to the modules. **Note that if you want to debug a module, you have to fill in the filename manually.**
Also note that the temporary file will currently not get killed when an error occurs to allow debugging of the module that broke the pipe. The temporary file will always be overwritten and the temporary directory will be cleaned automatically once you shut down your computer. So you don't have to worry about data accumulating.    

#### Input/output arguments ####

There are two different **classes** of arguments:
* **'hdf5_location'** corresponds to data that has to be produced upstream in the pipeline by another module, which saved it at the specified location in the HDF5 file. It is a string in the format of a unix path, e.g. "/myGroup/myDataset".
* **'parameter'** is an argument that is used to control the behavior of the module. It is module-specific and hence independent of other modules. It can be of any type (integer, string, array, ...). You can provide the optional **type** key to assert a specific data type for the passed argument. Note that this "type" is not YAML syntax but language specific, e.g. 'float64' in Python, 'double' in Matlab, 'Array{Float64,2}' in Julia or 'array' in R. Alternatively, this could be done in YAML syntax or in a custom data type syntax which will be mapped by the APIs. For now, we keep it in the syntax of the corresponding module.


## Modules ##

Jterator APIs are written in a way that enables more or less the same syntax in each language.  

Python example:     

```{python}
from jtapi import *
import os
import sys
import re


mfilename = re.search('(.*).py', os.path.basename(__file__)).group(1)


#########
# input #
#########

print('jt - %s:' % mfilename)

handles_stream = sys.stdin
handles = gethandles(handles_stream)
input_args = readinputargs(handles)
input_args = checkinputargs(input_args)


##############
# processing #
##############

# here comes your code

data = dict()
output_args = dict()


##########
# output #
##########

writedata(handles, data)
writeoutputargs(handles, output_args)

```

Matlab example:     

```{matlab}
import jtapi.*;


%%%%%%%%%
% input %
%%%%%%%%%

fprintf(sprintf('jt - %s:\n', mfilename));
cd(currentDirectory)
handles_stream = input_stream; % input_stream is provided by Mscript!
handles = gethandles(handles_stream);
input_args = readinputargs(handles);
input_args = checkinputargs(input_args);


%%%%%%%%%%%%%%
% processing %
%%%%%%%%%%%%%%

% here comes your code

data = struct();
output_args = struct();


%%%%%%%%%%
% output %
%%%%%%%%%%

writedata(handles, data)
writeoutputargs(handles, output_args)

```

### Mscript ###

Note that you need **Mscript** for the execution of Matlab scripts. Matlab scripts are no real executables and require a Matlab engine. In addition, they cannot accept STDIN. The standard Matlab engine also changes the current working directory to the location of the executed .m file. Mscript is a customized Julia-based Matlab engine based on [Julia's Matlab interface](https://github.com/JuliaLang/MATLAB.jl) that works around these annoying issues. It receives the standard input stream from Jterator and forwards it the Matlab session, enforces the current working directory and executes the module script. It also returns Matlab STDOUT and STDERR. 

We have also tried several existing Python Matlab engines, but didn't get any of them to work stably across platforms (Linux and OSX). Note that newer versions of Matlab (>2014b) come with a build in python matlab engine. But there is no backward compatibility. So for now, we stick to the Julia solution. 


## Getting started ##

To *download* Jterator clone this repository, do

```{bash}
git clone https://github.com/HackerMD/Jterator.git ~/jterator
```

To *install* the Jterator command line interface, do
```{bash}
cd ~/jterator
pip install -e .
```

Alternatively, you can add the Jterator directory to your executable path:

```{bash}
export PATH=$PATH:~/jterator/src/python
```
To make this permanent, include this line above in your .bash_profile file.
    

To *use Mscript* create a softlink in a directory on your PATH:

```{bash}
cd /usr/local/bin
ln -s ~/jterator/src/julia/mscript.jl Mscript
```

## How to ##

The command for Jterator is `jt`.

To display the help message, do
```{bash}
jt -h
```

To display the help message for subroutines (e.g. 'run'), do
```{bash}
jt run -h
```

To *create* a new Jterator project, do:

```{bash}
jt create --skel [skeleton_dir] [project_dir]
```

This will create your project folder and include skeletons for YAML descriptor files and modules.
Now you can place your custom code into the module skeletons and define the pipeline in the .pipe file as well as input/output arguments in the corresponding .handles files.

Now you are ready to go...

To *check* your YAML descriptor files (.pipe and .handles), do:

```{bash}
jt check [project_dir]
```

To *run* your pipeline in iterative mode, do:

```{bash}
jt run [project_dir]
```

To create a *joblist* for parallel computing, do:

```{bash}
jt joblist [project_dir]
```

To *run* individual jobs (parallel mode), do:

```{bash}
jt run --job [jobID] [project_dir]
```

To *run* a module individually for debugging purposes, do:

```{bash}
cat [handles_name] | [interpreter] [modules_name]
```
Example for a python module:
```{bash}
cat handles/myModule.handles | python modules/myModule.py
```
Note that this command works only after you have provided the correct value for the "hdf5_filename" key in the .handles file. 
There are some issues with debugging (e.g. in python) because 'cat' keeps the standard input blocked. Working on a solution...


## Developing Jterator ##

Modules can be written in any programming language that provides libraries for for *YAML* and *HDF5* file formats.
You are welcome to further extent the list of languages by writing additional APIs.


## Nose tests ##

We use nose framework to achieve code coverage with unit tests. In order to run tests, do

```{bash}
cd tests && nosetests
```

## To do ##

Package management for external dependencies and APIs in different languages. 

