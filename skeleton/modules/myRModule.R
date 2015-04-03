library(jterator)

mfilename <- basename(sub("--file=(.*).R", "\\1",
                      grep("--file=.*R", commandArgs(), value=TRUE)))

###############################################################################
## jterator input

cat(sprintf('jt - %s:\n', mfilename))

### read YAML from standard input
handles_stream <- file("stdin")

### retrieve handles from .YAML files
handles <- gethandles(handles_stream)

### read input arguments from .HDF5 files
input_args <- readinputargs(handles)

### check whether input arguments are valid
input_args <- checkinputargs(input_args)

###############################################################################

# here comes your code

data <- list()
output_args <- list()

###############################################################################
## jterator output

### write measurement data to HDF5
writedata(handles, data)

### write temporary pipeline data to HDF5
writeoutputargs(handles, output_args)

###############################################################################

