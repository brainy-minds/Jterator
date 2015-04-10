library(jtapi)

mfilename <- basename(sub("--file=(.*).R", "\\1",
                      grep("--file=.*R", commandArgs(), value=TRUE)))

#########
# input #
#########

cat(sprintf('jt - %s:\n', mfilename))

handles_stream <- file("stdin")
handles <- gethandles(handles_stream)
input_args <- readinputargs(handles)
input_args <- checkinputargs(input_args)


##############
# processing #
##############

# here comes your code

data <- list()
output_args <- list()


##########
# output #
##########

writedata(handles, data)
writeoutputargs(handles, output_args)
