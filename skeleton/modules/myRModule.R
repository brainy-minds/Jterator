#!/opt/local/bin/Rscript

source("/Users/Markus/Documents/Jterator/src/r/jterator/api/io.R")

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


## ----------------------------------------------------------------------------
## ------------------------------ module specific -----------------------------

####################
## input handling ##
####################


################
## processing ##
################


#################
## make figure ##
#################


####################
## prepare output ##
####################

output_args <- list()
output_tmp <- list()

## ------------------------------ module specific -----------------------------
## ----------------------------------------------------------------------------


###############################################################################
## jterator output

### write output data to HDF5
writeoutputargs(handles, output_args)
writeoutputtmp(handles, output_tmp)

###############################################################################
