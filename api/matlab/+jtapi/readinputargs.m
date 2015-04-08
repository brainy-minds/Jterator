%% Reading input arguments from HDF5 file
%% using the location specified in "handles".

function input_args = readinputargs(handles)

    import h5.*;
    import etc.*;
    

    hdf5_filename = handles.hdf5_filename;

    fid = H5F.open(hdf5_filename);

    input_args = struct();
    keys = fieldnames(handles.input);
    for i = 1:length(keys)
        key = keys{i};
        field = handles.input.(key);

        if isfield(field, 'hdf5_location')
            input_args.(key).variable = h5varget(fid, field.hdf5_location)';
            fprintf(sprintf('jt -- %s: loaded dataset ''%s'' from HDF5 location: "%s"\n', ...
                    mfilename, key, field.hdf5_location))
        elseif isfield(field, 'parameter')
            input_args.(key).variable = field.parameter;

            % temporary hack: this could also be fixed in ReadYaml.m
            % (more specifically in subfunction makematrices.m)
            if iscell(field.parameter)
                if all(cellfun(@isnumeric, field.parameter))
                    input_args.(key).variable = cell2mat(field.parameter);
                end
            end

            if ischar(field.parameter)
                fprintf(sprintf('jt -- %s: parameter ''%s'': "%s"\n', ...
                        mfilename, key, input_args.(key).variable))
            else
                fprintf(sprintf('jt -- %s: parameter ''%s'': %s\n', ...
                        mfilename, key, vec2str(input_args.(key).variable)))
            end
        else
            error('Possible variable keys are ''hdf5_location'' or ''parameter''');
        end 

        if isfield(field, 'type')
            input_args.(key).type = field.type;
        end

    end

    H5F.close(fid);
    
end
