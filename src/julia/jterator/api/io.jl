## This could also be a module, which could be made available to Julia by
## adding the commands to the ~/.juliarc.jl file:
## The variable LOAD_PATH should do the job, 
## but I haven't yet figured out how...

import YAML
import HDF5


function get_handles(handles_stream)
    ## Reading "handles" from YAML file.

    mfilename = "get_handles" # can we get this automatically?

    # Reading handles from YAML.
    handles = YAML.load(handles_stream)

    @printf("jt -- %s: loaded handles\n", mfilename)

    return handles

end


function read_input_args(handles)
    ## Reading input arguments from HDF5 file
    ## using the location specified in "handles".

    mfilename = "read_input_args"
    
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


function check_input_args(input_args)
    ##Checks input arguments for correct class and attributes.
    
    mfilename = "check_input_args"

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


function write_output_args(handles, output_args)
    ##Writing output arguments to HDF5 file
    ## using the location specified in "handles".

    mfilename = "write_output_args"

    hdf5_filename = handles["hdf5_filename"]
    hdf5_root = HDF5.h5open(hdf5_filename, "r+")

    for key in keys(output_args)
        hdf5_location = handles["output_keys"][key]["hdf5_location"]
        hdf5_root[hdf5_location] = output_args[key]
        @printf("jt -- %s: wrote dataset '%s' to HDF5 group: \"%s\"\n",
                mfilename, key, hdf5_location)
    end

    close(hdf5_root)

end


function write_output_tmp(handles, output_tmp)
    ## Writing output arguments to HDF5 file
    ## using the location specified in "handles".

    mfilename = "write_output_tmp"

    orig_substr = match(r"/data/(.*)\.data", hdf5_filename).captures[1]
    hdf5_filename = replace(hdf5_filename, r"/data/(.*)\.data$", 
                            @sprintf("/tmp/%s.tmp", orig_substr))
    hdf5_root = HDF5.h5open(hdf5_filename, "r+")

    for key in keys(output_tmp)
        hdf5_location = handles["output_keys"][key]["hdf5_location"]
        hdf5_root[hdf5_location] = output_tmp[key]
        @printf("jt -- %s: wrote tmp dataset '%s' to HDF5 group: \"%s\"\n",
                mfilename, key, hdf5_location)
    end

    close(hdf5_root)

end


function build_hdf5(handles)
    ## Create HDF5 file.

    mfilename = "build_hdf5"

    hdf5_filename = handles["hdf5_filename"]
    HDF5.h5open(hdf5_filename, "w")
    @printf("jt -- %s: created HDF5 file for measurement data: \"%s\"\n",
          mfilename, hdf5_filename)

    orig_substr = match(r"/data/(.*)\.data", hdf5_filename).captures[1]
    hdf5_filename = replace(hdf5_filename, r"/data/(.*)\.data$", 
                            @sprintf("/tmp/%s.tmp", orig_substr))
    HDF5.h5open(hdf5_filename, "w")
    @printf("jt -- %s: created HDF5 file for temporary pipe data: \"%s\"\n",
            mfilename, hdf5_filename)

end
