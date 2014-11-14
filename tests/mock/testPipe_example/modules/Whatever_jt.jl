#!/usr/bin/julia

include("/Users/Markus/Documents/Jterator/src/julia/jterator/api/io.jl")

###############################################################################
## jterator input

@printf("jt - %s\n", "Whatever_jt")

### read YAML from standard input
handles_stream = readall(STDIN)

### retrieve handles from .YAML files
handles = get_handles(handles_stream)

### read input arguments from .HDF5 files
input_args = read_input_args(handles)

### check whether input arguments are valid
input_args = check_input_args(input_args)

# ###############################################################################


# ## ----------------------------------------------------------------------------
# ## ------------------------------ module specific -----------------------------

# ####################
# ## input handling ##
# ####################


# ################
# ## processing ##
# ################


# #################
# ## make figure ##
# #################


# ####################
# ## prepare output ##
# ####################

# output_args = Dict()
# output_tmp = Dict()


# ## ------------------------------ module specific -----------------------------
# ## ----------------------------------------------------------------------------


# ###############################################################################
# ## jterator output

# write_output_args(handles, output_args)
# write_output_tmp(handles, output_tmp)

# ###############################################################################
