import jtapi.*;


%%%%%%%%%
% input %
%%%%%%%%%

fprintf(sprintf('jt - %s:\n', mfilename));

cd(currentDirectory)  % 'currentDirectory' is provided by Mscript

handles_stream = STDIN;  % 'STDIN' is provided by Mscript
handles = gethandles(handles_stream);
input_args = readinputargs(handles);
input_args = checkinputargs(input_args);


%%%%%%%%%%%%%%
% processing %
%%%%%%%%%%%%%%

% here comes your code

data = struct();
output_args = struct();


%%%%%%%%%%
% output %
%%%%%%%%%%

writedata(handles, data)
writeoutputargs(handles, output_args)
