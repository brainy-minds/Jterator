Jterator
========

[![Build Status](https://travis-ci.org/ewiger/Jterator.svg?branch=master)](https://travis-ci.org/ewiger/Jterator)


A minimalistic pipeline engine for scientific computing. It is designed to be flexible, but uncomplicated enough, so that no GUI is required to work with it.

* use simple format like JSON for basic parametrization whenever possible
** don't be afraid to keep your input settings on the disk
* for performance heavy IO use HDF5 
* used scientific data analysis.
* UNIX pipeline is a one great idea, but it is mostly restricted to text processing

Modules
-------


Think of your pipeline as a sequence of connected modules (a linked list). Each module is a program that get and reads JSON from on STDIN file descriptor.
Such JSON contains all the input settings required by the module.

Getting started 
---------------

Each pipeline has the following layout on the disk:

* **handles** folder contains all the JSON handles files, the are passed as STDIN to *modules*.
* **modules** folder contains all the executable plus code for programs corresponding
* **logs** folder contains all the output from STDOU and STERR streams, obtain for each executable that has been executed.
* **data** folder contains all the heavy data output like HDF5, etc. These data are shared between modules. 

Jterator allows only very simplistic type of workflow -  *pipeline* (somewhat similar to a UNIX-world pipeline). Description of such workflow must be put sibling to the folder structure described about, i.e. inside the Jterator pipeline (project) folder. Recognizable file name must be one of **['JteratorPipe.json', 'jt.pipe']**. Description is a JSON format. 

```json
{	
	"name": "Foo",
	"version": "0.0.1",	
	"pipeline": [
		{
			"name": "Bar",
			"module": "bar",
			"handles": "handles/some_bar"
		}, {
			"name": "Baz",
			"module": "baz",
			"handles": "handles/some_baz"
		}
	],
	"tests": [
		{
			"type": "hdf5_dependency",
			"module_name": "baz",
			"input": ["bar"],
			"output": ["baz"]
		}
	]
}

```

To *run* your first pipeline, do:

```bash
cd /my/first/jterator/pipeline/folder && jt run
```



Developing new modules
======================

This is a small walk-through on how to develop a new module for *Jterator*. Each module as to follow a particular convention of processing input  parameters. It can be written in virtually any programming language as long as such language can provide tools for working with *JSON* and *HDF5* data formats.

Developing Jterator
===================

Latest code is available at https://github.com/ewiger/Jterator

Nose tests
----------

We use nose framework to achieve code coverage with unit tests. In order to run tests, do

```bash
cd tests && nosetests
```
