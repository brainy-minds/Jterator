#!/usr/bin/julia
using MATLAB

# Note: we could include a first line into the actual Matlab script for making
# it executable. But we would then have to get rid of this line again for the
# actual Matlab execution. We could write a temporary files without this line
# for Matlab -> using mktemp() ???
 
# get filename of Matlab script
script_filename = ARGS[1]
if ~isabspath(script_filename)
    script_filename = joinpath(pwd(), script_filename)
end

# get YAML stream from standard input
handles_stream = readall(STDIN)

# start Matlab session
s1 = MSession()
print("\nMscript: start of Matlab session\n\n")

# send YAML stream into Matlab session
put_variable(s1, :handles_stream, handles_stream)

# send filename of script into Matlab session
put_variable(s1, :matlab_script, script_filename)

# run script within Matlab session
eval_string(s1, "run(matlab_script)")

# # evaluate Matlab script line by line
# for line in matlab_script
#     eval_string(s1, line) 
# end

# close Matlab session
print("\nMscript: end of Matlab session\n\n")
# close(s1)  # this doesn't work somehow!
