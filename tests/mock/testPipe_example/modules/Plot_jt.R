#!/opt/local/bin/Rscript
library(jsonlite)
library(jterator, lib="/Users/Markus/Documents/Jterator/src/r/jterator")

mfilename <- basename(sub("--file=(.*).R", "\\1",
                      grep("--file=.*R", commandArgs(), value=TRUE)))

# redirect output to log file
sink(sprintf('logs/%s.output', mfilename))

###############################################################################
## jterator input

cat(sprintf('jt - %s:\n', mfilename))

### standard input
handles_filename <- file("stdin")

### retrieve handles from .YAML files
handles <- get_handles(handles_filename)

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

nuclei_area <- input_args$Data2Plot
makePlot <- input_args$MakePlot


################
## processing ##
################


#################
## make figure ##
#################

if (makePlot) {

    library(ggplot2)

    ### make figure with ggplot2
    fig <- qplot(nuclei_area, geom="histogram", binwidth=500)

    ### save figure as PDF file
    pdf(sprintf("figures/%s.pdf", mfilename))
    print(fig)
    dev.off()

    #### send ggplot figure to plotly
    # library(plotly)
    # py <- plotly()
    # py$ggplotly()

}


####################
## prepare output ##
####################

output_args = list()

output_tmp <- list()
output_tmp[['NuclearArea']] <- nuclei_area

## ------------------------------ module specific -----------------------------
## ----------------------------------------------------------------------------


###############################################################################
## jterator output

write_output_args(handles, output_args)

### stop writing standard output to file
sink()

### now we could send data to standard output
toJSON(output_tmp)

###############################################################################
