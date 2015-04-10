import jtapi.*;


%%%%%%%%%
% input %
%%%%%%%%%

fprintf(sprintf('jt - %s:\n', mfilename));
cd(currentDirectory)

handles_stream = STDIN; % STDIN is provided by Mscript!
handles = gethandles(handles_stream);
input_args = readinputargs(handles);
input_args = checkinputargs(input_args);

%%%%%%%%%%%%%%
% processing %
%%%%%%%%%%%%%%

InputVar1 = input_args.InputVar1;

fprintf('>>>>> "InputVar1" has type "%s" and dimensions "%s".\n', ...
      	char(class(InputVar1)), mat2str(size(InputVar1)));

fprintf('>>>>> position (2, 3) (1-based): %d\n', InputVar1(2, 3));

data = struct();
output_args = struct();
output_args.OutputVar = InputVar1;

%%%%%%%%%%
% output %
%%%%%%%%%%

writedata(handles, data)
writeoutputargs(handles, output_args)
