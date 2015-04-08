%% Checks input arguments for correct type (i.e. class).

function checked_input_args = checkinputargs(input_args)

    names = fieldnames(input_args); 
    for i = 1:length(names)
        arg = input_args.(names{i});
        if isfield(arg, 'type')
            if ~strcmp(arg.type, class(arg.variable))
                error('argument "%s" is of class "%s" instead of expected "%s"', ...
                      names{i}, class(arg.variable), arg.type)
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
