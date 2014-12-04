## What's the best way of making this module available to Julia?
## Currently, I'm including it in the ~/.juliarc.jl.
## There has to be a better way, though. The variable LOAD_PATH should do the job, 
## but I haven't yet figured out how...

module jterator

import YAML
import HDF5


function gethandles(handles_stream)
    ## Reading "handles" from YAML file.

    mfilename = "gethandles" # can we get this automatically?

    # Reading handles from YAML.
    handles = YAML.load(handles_stream)

    @printf("jt -- %s: loaded handles\n", mfilename)

    return handles

end


function readinputargs(handles)
    ## Reading input arguments from HDF5 file
    ## using the location specified in "handles".

    mfilename = "readinputargs"
    
    hdf5_filename = handles["hdf5_filename"]

    input_args = Dict()
    for key in keys(handles["input_keys"])
        field = handles["input_keys"][key]
        input_args[key] = Dict()

        if haskey(field, "hdf5_location")
            input_args[key]["variable"] = HDF5.h5read(hdf5_filename, field["hdf5_location"])
            @printf("jt -- %s: loaded dataset '%s' from HDF5 group: \"%s\"\n", mfilename, key, field["hdf5_location"])
        elseif haskey(field, "parameter")
            input_args[key]["variable"] = field["parameter"]
            @printf("jt -- %s: parameter '%s': \"%s\"\n", mfilename, key, input_args[key]["variable"])          
        else
            error("Possible variable keys are \"hdf5_location\" or \"parameter\"")
        end 

        if haskey(field, "class")
            input_args[key]["class"] = field["class"]
        else
            input_args[key]["class"] = []
        end

        if haskey(field, "attributes")
            input_args[key]["attributes"] = field["attributes"]
        else
            input_args[key]["attributes"] = []
        end   

    end

    return input_args
    
end


function checkinputargs(input_args)
    ##Checks input arguments for correct class and attributes.
    
    mfilename = "checkinputargs"

    checked_input_args = Dict()
    for key in keys(input_args)

        # checks are only done if "class" is specified
        if haskey(input_args[key], "class")
            expected_class = input_args[key]["class"]
            loaded_class = typeof(input_args[key]["variable"])

            if ~isequal(string(loaded_class), expected_class) 
                error(@sprintf("argument \"%s\" is of class \"%s\" instead of expected \"%s\"", 
                      key, loaded_class, expected_class))
            end

            @printf("jt -- %s: argument \"%s\" passed check\n", mfilename, key)

        else
            @printf("jt -- %s: argument \"%s\" not checked\n", mfilename, key)
        end

        # return parameters in simplified form
        checked_input_args[key] = input_args[key]["variable"]

    end

    return checked_input_args

end


function writeoutputargs(handles, output_args)
    ##Writing output arguments to HDF5 file
    ## using the location specified in "handles".

    mfilename = "writeoutputargs"

    orig_substr = match(r"/tmp/(.*)\.tmp", hdf5_filename).captures[1]
    hdf5_filename = replace(hdf5_filename, r"/tmp/(.*)\.tmp$", 
                            @sprintf("/data/%s.data", orig_substr))
    hdf5_root = HDF5.h5open(hdf5_filename, "r+")

    for key in keys(output_args)
        hdf5_location = handles["output_keys"][key]["hdf5_location"]
        hdf5_root[hdf5_location] = output_args[key]
        @printf("jt -- %s: wrote dataset '%s' to HDF5 group: \"%s\"\n",
                mfilename, key, hdf5_location)
    end

    close(hdf5_root)

end


function writeoutputtmp(handles, output_tmp)
    ## Writing output arguments to HDF5 file
    ## using the location specified in "handles".

    mfilename = "writeoutputtmp"

    hdf5_filename = handles["hdf5_filename"]
    hdf5_root = HDF5.h5open(hdf5_filename, "r+")

    for key in keys(output_tmp)
        hdf5_location = handles["output_keys"][key]["hdf5_location"]
        hdf5_root[hdf5_location] = output_tmp[key]
        @printf("jt -- %s: wrote tmp dataset '%s' to HDF5 group: \"%s\"\n",
                mfilename, key, hdf5_location)
    end

    close(hdf5_root)

end


function buildhdf5(handles)
    ## Create HDF5 file.

    mfilename = "buildhdf5"

    hdf5_filename = handles["hdf5_filename"]
    HDF5.h5open(hdf5_filename, "w")
    @printf("jt -- %s: created HDF5 file for temporary data: \"%s\"\n",
          mfilename, hdf5_filename)

    orig_substr = match(r"/tmp/(.*)\.tmp", hdf5_filename).captures[1]
    hdf5_filename = replace(hdf5_filename, r"/tmp/(.*)\.tmp$", 
                            @sprintf("/data/%s.data", orig_substr))
    HDF5.h5open(hdf5_filename, "w")
    @printf("jt -- %s: created HDF5 file for measurement pipe data: \"%s\"\n",
            mfilename, hdf5_filename)

end

export get_handles, read_input_args, check_input_args, write_output_args, 
write_output_tmp, build_hdf5

end
