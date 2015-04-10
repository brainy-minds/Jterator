importall jtapi

mfilename = match(r"([^/]+)\.jl$", @__FILE__()).captures[1]

#########
# input #
#########

@printf("jt - %s\n", mfilename)

handles_stream = readall(STDIN)
handles = gethandles(handles_stream)
input_args = readinputargs(handles)
input_args = checkinputargs(input_args)


##############
# processing #
##############

InputVar1 = input_args["InputVar1"]

@printf(">>>>> \"InputVar1\" has type \"%s\" and dimensions \"%s\".\n",
        string(typeof(InputVar1)), string(size(InputVar1)))


data = Dict()
output_args = Dict()
output_args["OutputVar1"] = InputVar1
output_args["OutputVar2"] = "test"


##########
# output #
##########

writedata(handles, data)
writeoutputargs(handles, output_args)
