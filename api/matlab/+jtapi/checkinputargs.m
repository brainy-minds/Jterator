%% Checks input arguments for correct class and attributes.

function checked_input_args = checkinputargs(input_args)

    names = fieldnames(input_args); 
    for i = 1:length(names)
        arg = input_args.(names{i});
        if isfield(arg, 'class')
            if ~strcmp(arg.class, class(arg.variable))
                error('argument "%s" is of class "%s" instead of expected "%s"', ...
                      names{i}, class(arg.variable), arg.class)
            end
            fprintf(sprintf('jt -- %s: argument ''%s'' passed check\n', ...
                    mfilename, names{i}));
        else
            fprintf(sprintf('jt -- %s: argument ''%s'' not checked\n', ...
                        mfilename, names{i}));
        end
    end

    % return parameters in simplified form
    checked_input_args = struct();
    for i = 1:length(names)
        checked_input_args.(names{i}) = input_args.(names{i}).variable;
    end
    
end
