importall jterator

mfilename = match(r"([^/]+)\.jl$", @__FILE__()).captures[1]

###############################################################################
## jterator input

@printf("jt - %s\n", mfilename)

### read YAML from standard input
handles_stream = readall(STDIN)

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

output_args = Dict()
output_tmp = Dict()


###############################################################################
## jterator output

### write output data to HDF5
writeoutputargs(handles, output_args)
writeoutputtmp(handles, output_tmp)

###############################################################################
