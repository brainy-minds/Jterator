#!/usr/bin/Rscript

jt_path <- "/Users/Markus/Documents/Jterator"
source(list.files(jt_path, pattern = "io\\.R$", full.names = TRUE, recursive = TRUE)[[1]])

args <- commandArgs()

cat(sprintf('jt - %s:\n', basename(grep("--file=(.*)", args, value = TRUE))))

### read actual input argument
handles_filename <- commandArgs(TRUE)

###############################################################################
## jterator input

### retrieve handles from .JSON files
handles = get_handles(handles_filename)

### read input arguments from .HDF5 files
input_args = read_input_args(handles)

### check whether input arguments are valid
input_args = check_input_args(input_args)

###############################################################################


## ----------------------------------------------------------------------------
# ------------------------------ module specific ------------------------------

####################
## input handling ##
####################

nuclei_area <- input_args$Data2Plot
makePlot <- input_args$MakePlot


################
## processing ##
################

cat(sprintf("--> biggest nucleus (probably a clump of nuclei) is %d pixel\n",
    max(nuclei_area)))


#################
## make figure ##
#################

if (makePlot) {

    cat(sprintf("--> Check this out: YAML works with logical input :)\n"))

}


####################
## prepare output ##
####################

output_args = list()

# ------------------------------ module specific ------------------------------
## ----------------------------------------------------------------------------


###############################################################################
## jterator output

write_output_args(handles, output_args)

###############################################################################
