%% Reading input arguments from HDF5 file
%% using the location specified in "handles".

function input_args = readinputargs(handles)

    import h5.*;
    import etc.*;
    

    hdf5_filename = handles.hdf5_filename;

    fid = H5F.open(hdf5_filename);

    required_keys = {'name', 'value', 'class'};

    input_args = struct();
    for i = 1:length(handles.input)
        arg = handles.input{i};
        key = arg.name;
        for k = required_keys
            if ~isfield(arg, k)
                error('Input argument ''%s'' requires ''%s'' key.', key, k)
            end
        end

        if strcmp(arg.class, 'hdf5_location')
            input_args.(key).variable = h5varget(fid, arg.value)';
            fprintf('jt -- %s: loaded dataset ''%s'' from HDF5 location: "%s"\n', ...
                    mfilename, key, arg.value);
        elseif strcmp(arg.class, 'parameter')
            % Temporary hack around bug: wrong handling of arrays (i.e. matrices)
            % This could also be fixed in ReadYaml.m
            % (more specifically in subfunction makematrices.m)
            if iscell(arg.value)
                if all(cellfun(@isnumeric, arg.value))
                    input_args.(key).variable = cell2mat(arg.value);
                end
            else
                input_args.(key).variable = arg.value;
            end

            if ischar(arg.value)
                fprintf('jt -- %s: parameter ''%s'': "%s"\n', ...
                        mfilename, key, input_args.(key).variable);
            else
                fprintf('jt -- %s: parameter ''%s'': %s\n', ...
                        mfilename, key, vec2str(input_args.(key).variable));
            end
        else
            error('Possible values for ''class'' key are ''hdf5_location'' or ''parameter''');
        end 

        if isfield(arg, 'type')
            input_args.(key).type = arg.type;
        end
    end

    H5F.close(fid);
    
end
