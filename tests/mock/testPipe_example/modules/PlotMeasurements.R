library(jsonlite)

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


####################
## input handling ##
####################

nuclei_area <- input_args$Data2Plot
makePlot <- input_args$MakePlot


################
## processing ##
################


#####################
## display results ##
#####################

if (makePlot) {

    library(ggplot2)

    ### make figure with ggplot2
    fig <- qplot(nuclei_area, geom="histogram", binwidth=500)

    ### save figure as PDF file
    pdf(sprintf("figures/%s.pdf", mfilename))
    print(fig)
    dev.off()

    # ### send ggplot figure to plotly
    # library(plotly)
    # py <- plotly()
    # py$ggplotly()

}


####################
## prepare output ##
####################

output_args <- list()

data <- list()
data[['NuclearArea']] <- nuclei_area


###############################################################################
## jterator output

writeoutputargs(handles, output_args)
writedata(handles, data)

###############################################################################
