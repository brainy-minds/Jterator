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

# here comes your code

data = Dict()
output_args = Dict()


###############################################################################
## jterator output

### write measurement data to HDF5
writedata(handles, data)

### write temporary pipeline data to HDF5
writeoutputargs(handles, output_args)

###############################################################################
