#!/usr/bin/env python
import jterator
import sys
import os
import h5py as h5


# this module is the python entry point
def read_filenames(input_args):

    # -------------------------------------------------------------------------

    # here comes the actual processing

    # -------------------------------------------------------------------------

    return output_args


# wrapper for Jterator
if __name__ == '__main__':
    handles = jterator.module.get_handles()
    input_args = jterator.module.read_input_args(handles)
    output_args = read_filenames(**input_args)
    jterator.module.write_output_args(handles, output_args)
