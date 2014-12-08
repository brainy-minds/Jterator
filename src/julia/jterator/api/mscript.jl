#!/usr/bin/julia
using MATLAB

# This Julia script turns a Matlab script into a real executable.
# The actual script requires a shebang (first line starting with #!) and the
# full path to this script or to a link in a stable directory, e.g. /usr/bin.
# 
# The approach requires an installation of Julia:
#  - install application: http://julialang.org/downloads/
#  - install from source: https://github.com/JuliaLang/julia
# 
# It further depends on the Julia "MATLAB" package: 
#  see https://github.com/JuliaLang/MATLAB.jl
#
# Author: Markus Herrmann <markus.herrmann@imls.uzh.ch>

 
# get filename of Matlab script
script_path = ARGS[1]
if ~isabspath(script_path)
    script_path = joinpath(pwd(), script_path)
end

# create a temporary Matlab interpretable .m file: 
(matlab_script_path, matlab_script_io) = mktemp()
# change the filename; required for error reports
mfilename = match(r"(.*)\.jt", basename(script_path)).captures[1]
mfilename = @sprintf("%s", mfilename)
matlab_script_path_new = replace(matlab_script_path, basename(matlab_script_path), mfilename)
# add ".m" suffix; required for execution of the script by Matlab
mv(matlab_script_path, @sprintf("%s.m", matlab_script_path_new))
# replace the shebang line; required for execution of the script by Matlab
script_stream = open(script_path) 
for line in eachline(script_stream)
    if line[1]=='#'
        write(matlab_script_io, "%% This file was created by Mscript %%")
    end
    write(matlab_script_io, line)
end
close(matlab_script_io)

# get standard input
input_stream = readall(STDIN)

# start Matlab session
s1 = MSession()
print("Mscript: start of Matlab session\n")

# send YAML stream into Matlab session
print("Mscript: forward standard input\n")
put_variable(s1, :input_stream, input_stream)

# send filename of script into Matlab session
print("Mscript: forward full path to the Matlab script\n")
put_variable(s1, :matlab_script, matlab_script_path_new)

# fake mfilename (unfortunately, this doesn't work for error handling)
print("Mscript: forward name of the Matlab script\n")
put_variable(s1, :mfilename, mfilename)

# send current working directory into Matlab session
print("Mscript: forward current working directory\n")
put_variable(s1, :currentDirectory, pwd())

# run script within Matlab session
print("Mscript: evaluate Matlab script ...\n\n")
eval_string(s1, "run(matlab_script)")

## It could also work with evaluation of the script as concatenated string
## using 'evalin':
# eval_string(s1, "evalin('base', [script ';']);")

## We could also execute the script line by line,
## but this is less optimal in terms of performance and error handling is lost.
# for line in matlab_script
#     eval_string(s1, line) 
# end

# close Matlab session
# close(s1)  # this doesn't work somehow!

# remove temporary file
rm(@sprintf("%s.m", matlab_script_path_new))
