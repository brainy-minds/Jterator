Jterator
========

A minimalistic pipeline engine for scientific computing. It is designed to be flexible, but at the same time handy to work with. Jterator is a command-line tool for Unix systems. It comes without a GUI, but rather makes use of easily readable and modifiable YAML files. Figures can either be saved as PDF files or plotted in the browser using d3 technology.


Languages
---------

Jterator is written in Python but can pipe custom code in different languages. APIs for input/output handling are currently implemented in the following languages: 
* Matlab
* R
* Python
* Julia


External libraries
------------------

Jterator depends on the following languages and external libraries:

* Python: 
    
    https://www.python.org/downloads/

* Julia (required for Mscript)

    http://julialang.org/downloads/

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
* **tmp** folder contains the temporary pipeline data that is shared between modules. These files are killed after successful completion of the pipeline.
* **figures** folder contains the PDFs of the plots (optional).

Jterator allows only very simplistic type of work-flow -  *pipeline* (somewhat similar to a UNIX-world pipeline). Description of such work-flow must be put sibling to the folder structure described about, i.e. inside the Jterator project folder. Recognizable file name must be **'[ProjectName].pipe'**. Description is a YAML format. 


Getting started
---------------

To *download* Jterator clone this repository:

```bash
git clone git@github.com:HackerMD/Jterator.git
```

To *link* Mscript - a custom tool based on the Julia Matlab interface (https://github.com/JuliaLang/MATLAB.jl) for transforming Matlab scripts into real executables - into /usr/bin for easier execution, do:

```bash
sudo ln -s /local/copy/of/Jterator/src/julia/jterator/api/mscript.jl Mscript
```

To *create* a new jterator project, do:

```bash
jt create [/my/jterator/project/folder] --skel [/my/repository/with/jterator/skeleton]
```

This will create your project folder, which will then already have the correct folder layout and will contain skeletons for YAML descriptor files and modules. It will also provide you with the required APIs.
Now you will have to place your custom code into the module skeletons and define the pipeline in the .pipe file as well as input/output arguments in the corresponding .handles files. Shabam! You are ready to go...

To *check* your existing jterator project (YAML descriptor files), do:

```bash
jt check [/my/jterator/project/folder]
```

To *run* your pipeline, do:

```bash
jt check [/my/jterator/project/folder]
```

To create a *joblist* for parallel computing, do:

```bash
jt joblist [/my/jterator/project/folder]
```

To *run* your pipeline in *parallel* mode, do:

```bash
jt check [/my/jterator/project/folder] --job [jobID]
```

To *run* a module individually for debugging purposes, do:

```bash
cat handles/myModule.handles | [interpreter] modules/myModule.py
```

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
