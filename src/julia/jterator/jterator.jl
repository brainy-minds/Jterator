module jterator

using YAML
using HDF5

export gethandles, readinputargs, checkinputargs, writeoutputargs, writedata

###################################################################
## Note: the HDF5 package doesn't handle dimensions correctly!!! ##
###################################################################

function gethandles(handles_stream)
    ## Reading "handles" from YAML file.

    mfilename = "gethandles"

    # Reading handles from YAML.
    handles = YAML.load(handles_stream)

    @printf("jt -- %s: loaded 'handles'\n", mfilename)

    return handles

end


function readinputargs(handles)
    ## Reading input arguments from HDF5 file
    ## using the location specified in "handles".

    mfilename = "readinputargs"
    
    hdf5_filename = handles["hdf5_filename"]

    input_args = Dict()
    if ~isempty(handles)
        for key in keys(handles["input"])
            field = handles["input"][key]
            input_args[key] = Dict()

            if haskey(field, "hdf5_location")
                input_args[key]["variable"] = HDF5.h5read(hdf5_filename, field["hdf5_location"])
                if ismatch(r"Array", string(typeof(input_args[key]["variable"])))
                    input_args[key]["variable"] = input_args[key]["variable"]'
                end
                @printf("jt -- %s: loaded dataset '%s' from HDF5 group: \"%s\"\n", mfilename, key, field["hdf5_location"])
            elseif haskey(field, "parameter")
                input_args[key]["variable"] = field["parameter"]
                @printf("jt -- %s: parameter '%s': \"%s\"\n", mfilename, key, input_args[key]["variable"])          
            else
                error("Possible variable keys are \"hdf5_location\" or \"parameter\"")
            end 

            if haskey(field, "class")
                input_args[key]["class"] = field["class"]
            end 
        end
    end

    return input_args
    
end


function checkinputargs(input_args)
    ##Checks input arguments for correct class and attributes.
    
    mfilename = "checkinputargs"

    checked_input_args = Dict()
    if ~isempty(input_args)
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
    end

    return checked_input_args

end


function writedata(handles, data)
    ## Writing data to HDF5 file.

    mfilename = "writedata"

    if ~isempty(data)
        hdf5_filename = HDF5.h5read(handles["hdf5_filename"], "datafile")
        hdf5_data = HDF5.h5open(hdf5_filename, "r+")
        for key in keys(data)
            hdf5_location = handles["output"][key]["hdf5_location"]
            if ismatch(r"Array", string(typeof(data[key])))
                HDF5.h5write(hdf5_filename, hdf5_location, data[key]')
            else
                HDF5.h5write(hdf5_filename, hdf5_location, data[key])
            end
            @printf("jt -- %s: wrote dataset '%s' to HDF5 group: \"%s\"\n",
                    mfilename, key, hdf5_location)
        end
        close(hdf5_data)
    end

end


function writeoutputargs(handles, output_args)
    ## Writing output arguments to HDF5 file
    ## using the location specified in "handles".

    mfilename = "writeoutputargs"

    hdf5_filename = handles["hdf5_filename"]
    
    if ~isempty(output_args) 
        hdf5_tmp = HDF5.h5open(hdf5_filename, "r+")
        for key in keys(output_args)
            hdf5_location = handles["output"][key]["hdf5_location"]
            if ismatch(r"Array", string(typeof(output_args[key])))
                HDF5.h5write(hdf5_filename, hdf5_location, output_args[key]')
            else
                HDF5.h5write(hdf5_filename, hdf5_location, output_args[key])
            end
            @printf("jt -- %s: wrote tmp dataset '%s' to HDF5 group: \"%s\"\n",
                    mfilename, key, hdf5_location)
        end
        close(hdf5_tmp)
    end

end

end
