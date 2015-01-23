library(devtools)
library(roxygen2)

setwd("/Users/Markus/Documents/Jterator/src/r/jterator/")
document()

setwd("..")
install("jterator")

library(jterator)