function input_args = check_input_args(input_args)

    % check whether input arguments were correctly specified in handles
    names = fieldnames(input_args); 
    for i = 1:length(names)
        validateattributes(input_args.(names{i}).data, ...
                           input_args.(names{i}).class, ...
                           input_args.(names{i}).attributes, ...
                           names{i});
    end
    
end
