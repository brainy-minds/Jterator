%% Reading initial values from "handles".

function values = read_input_values(handles)

    values = struct();
    keys = fieldnames(handles.input_keys);
    for i = 1:length(keys)
        key = keys{i};
        values.(key) = handles.input_keys.(key).value;
        fprintf('jt -- %s: value ''%s'': "%s"\n', ...
            mfilename, key, values.(key))
    end
    
end
