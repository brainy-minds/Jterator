#!/opt/local/bin/Rscript

library(jterator, lib="/Users/Markus/Documents/Jterator/src/r/jterator")

mfilename <- basename(sub("--file=(.*).R", "\\1",
                      grep("--file=.*R", commandArgs(), value=TRUE)))

###############################################################################
## jterator input

cat(sprintf('jt - %s:\n', mfilename))

### read YAML from standard input
handles_stream <- file("stdin")

### retrieve handles from .YAML files
handles <- get_handles(handles_stream)

### read input arguments from .HDF5 files
input_args <- read_input_args(handles)

### check whether input arguments are valid
input_args <- check_input_args(input_args)

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
write_output_args(handles, output_args)
write_output_tmp(handles, output_tmp)

###############################################################################
