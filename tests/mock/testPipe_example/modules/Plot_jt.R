#!/opt/local/bin/Rscript

library(jterator, lib="/Users/Markus/Documents/Jterator/src/r/jterator")

mfilename <- basename(sub("--file=(.*).R", "\\1",
                      grep("--file=.*R", commandArgs(), value=TRUE)))
cat(sprintf('jt - %s:\n', mfilename))

# ### standard input
handles_filename <- file("stdin")

###############################################################################
## jterator input

### retrieve handles from .YAML files
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


#################
## make figure ##
#################

if (makePlot) {

    cat(sprintf("--> Check this out: YAML works with logical input :)\n"))

    cat(sprintf("--> Shabam: now we plot in the brower :)\n"))

    library(plotly)

    ### make ggplot figure
    qplot(nuclei_area, geom="histogram", binwidth=500)

    #### send ggplot figure to plotly
    # py <- plotly()
    # py$ggplotly()

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
