#!/usr/bin/julia
using MATLAB

# This Julia script turns a Matlab script into a real executable, which 
# can accept standard input within a PIPE.
#
# The approach requires an installation of Julia:
#  - install application: http://julialang.org/downloads/
#  - install from source: https://github.com/JuliaLang/julia
# 
# It further depends on the Julia "MATLAB" package: 
#  see https://github.com/JuliaLang/MATLAB.jl
#
# General note: 
# This engine approach via Julia seems to be the best option out there.
# However, the startup time of Julia is yet very slow. So you thus should avoid
# using the Mscript routine for small problems.
#
# Author: Markus Herrmann <markus.herrmann@imls.uzh.ch>

 
# get filename of Matlab script
script_path = ARGS[1]
if ~isabspath(script_path)
    script_path = joinpath(pwd(), script_path)
end

# get standard input
input_stream = readall(STDIN)

# start Matlab session
print("Mscript: Julia is happy to do MATLAB's job :)\nMscript: ")
s1 = MSession()

# send standard input stream into Matlab session
print("Mscript: forward standard input to Matlab\n")
put_variable(s1, :input_stream, input_stream)

# send current working directory into Matlab session
print("Mscript: forward current working directory to Matlab\n")
put_variable(s1, :currentDirectory, pwd())

# run script within Matlab session
print("Mscript: run Matlab script ...\n\n")
eval_string(s1, @sprintf("run(\'%s\')", script_path))
