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

# here comes your code

data = Dict()
output_args = Dict()


##########
# output #
##########

writedata(handles, data)
writeoutputargs(handles, output_args)
