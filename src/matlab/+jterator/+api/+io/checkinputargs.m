%% Checks input arguments for correct class and attributes.

function checked_input_args = checkinputargs(input_args)

    names = fieldnames(input_args); 
    for i = 1:length(names)
        arg = input_args.(names{i});
        validateattributes(arg.variable, ...
                           arg.class, ...
                           arg.attributes, ...
                           names{i});
        fprintf(sprintf('jt -- %s: argument ''%s'' passed check\n', ...
                    mfilename, names{i}));
    end

    % return parameters in simplified form
    checked_input_args = struct();
    for i = 1:length(names)
        checked_input_args.(names{i}) = input_args.(names{i}).variable;
    end
    
end
