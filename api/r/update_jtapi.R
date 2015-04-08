#! Rscript

library(devtools)
library(roxygen2)

setwd("/Users/mdh/jterator/api/r/jtapi")
document()

setwd("..")
install("jtapi")

# library(jtapi)
