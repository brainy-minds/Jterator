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

InputVar1 <- input_args$InputVar1

cat(sprintf('>>>>> "InputVar1" has type "%s" and dimensions "%s".\n',
      		toString(typeof(InputVar1)), toString(dim(InputVar1))))

cat(sprintf('>>>>> position [2, 3] (1-based): %d\n', InputVar1[2, 3]))

data <- list()
output_args <- list()
output_args[['OutputVar']] <- InputVar1


##########
# output #
##########

writedata(handles, data)
writeoutputargs(handles, output_args)
