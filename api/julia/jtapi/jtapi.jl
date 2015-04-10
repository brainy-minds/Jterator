module jtapi

using YAML
using HDF5

export gethandles, readinputargs, checkinputargs, writeoutputargs, writedata


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

    fid = h5open(hdf5_filename, "r")

    required_keys = ["name", "value", "class"]

    input_args = Dict()
    if ~isempty(handles)
        for arg in handles["input"]
            key = arg["name"]
            for k in required_keys
                if ~haskey(arg, k)
                    error(@sprintf("Input argument '%s' requires '%s' key.", key, k))
                end
            end

            input_args[key] = Dict()
            if arg["class"] == "hdf5_location"
                input_args[key]["variable"] = read(fid, arg["value"])
                if ismatch(r"Array", string(typeof(input_args[key]["variable"])))
                    # ???
                    input_args[key]["variable"] = input_args[key]["variable"]'
                end
                @printf("jt -- %s: loaded dataset '%s' from HDF5 location: \"%s\"\n",
                        mfilename, key, arg["value"])
            elseif arg["class"] ==  "parameter"
                if arg["value"] == "Yes"
                    # hack around bug in YAML package (boolean not recognized)
                    input_args[key]["variable"] = true
                else
                    input_args[key]["variable"] = arg["value"]
                end
                @printf("jt -- %s: parameter '%s': \"%s\"\n", mfilename, key, arg["value"])          
            else
                error("Possible values for 'class' key are 'hdf5_location' or 'parameter'")
            end 

            if haskey(arg, "type")
                input_args[key]["type"] = arg["type"]
            end 
        end
    end

    close(fid)

    return input_args
    
end


function checkinputargs(input_args)
    ##Checks input arguments for correct type and attributes.
    
    mfilename = "checkinputargs"

    checked_input_args = Dict()
    if ~isempty(input_args)
        for key in keys(input_args)

            # checks are only done if "type" is specified
            if haskey(input_args[key], "type")
                expected_type = input_args[key]["type"]
                loaded_type = typeof(input_args[key]["variable"])

                if ~isequal(string(loaded_type), expected_type) 
                    error(@sprintf("argument '%s' is of type \"%s\" instead of expected \"%s\"", 
                          key, loaded_type, expected_type))
                end

                @printf("jt -- %s: argument '%s' passed check\n", mfilename, key)

            else
                @printf("jt -- %s: argument '%s' not checked\n", mfilename, key)
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
        hdf5_filename = h5read(handles["hdf5_filename"], "datafile")
        hdf5_data = h5open(hdf5_filename, "r+")
        for key in keys(data)
            hdf5_location = keys(key)
            if ismatch(r"Array", string(typeof(data[key])))
                write(hdf5_data, hdf5_location, data[key]')
            else
                write(hdf5_data, hdf5_location, data[key])
            end
            @printf("jt -- %s: wrote dataset '%s' to HDF5 location: \"%s\"\n",
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
        hdf5_tmp = h5open(hdf5_filename, "r+")
        for key in keys(output_args)
            ix = find([i["name"] == key for i in handles["output"]])[1]
            hdf5_location = handles["output"][ix]["value"]
            if ismatch(r"Array", string(typeof(output_args[key])))
                write(hdf5_tmp, hdf5_location, output_args[key]')
            else
                write(hdf5_tmp, hdf5_location, output_args[key])
            end
            @printf("jt -- %s: wrote tmp dataset '%s' to HDF5 location: \"%s\"\n",
                    mfilename, key, hdf5_location)
        end
        close(hdf5_tmp)
    end

end

end
