%% Reading input arguments from HDF5 file
%% using the location specified in "handles".

function input_args = read_input_args(handles)

    import jterator.api.h5.*;
    import jterator.api.etc.*;
    

    hdf5_filename = handles.hdf5_filename;

    input_args = struct();
    keys = fieldnames(handles.input_keys);
    for i = 1:length(keys)
        key = keys{i};
        field = handles.input_keys.(key);

        if isfield(field, 'hdf5_location')
            input_args.(key).variable = h5varget(hdf5_filename, field.hdf5_location);
            fprintf(sprintf('jt -- %s: loaded dataset ''%s'' from HDF5 group: "%s"\n', ...
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

        if isfield(field, 'class')
            input_args.(key).class = {field.class};
        else
            input_args.(key).class = {};
        end

        if isfield(field, 'attributes')
            input_args.(key).attributes = {field.attributes};
        else
            input_args.(key).attributes = {};
        end   

    end
    
end
