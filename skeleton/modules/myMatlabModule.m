import jterator.*;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% jterator input

fprintf(sprintf('jt - %s:\n', mfilename));

%%% read standard input
handles_stream = input_stream; % input_stream is provided by Mscript!

%%% change current working directory
cd(currentDirectory)

%%% retrieve handles from .YAML files
handles = gethandles(handles_stream);

%%% read input arguments from .HDF5 files
input_args = readinputargs(handles);

%%% check whether input arguments are valid
input_args = checkinputargs(input_args);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% here comes your code

data = struct();
output_args = struct();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% jterator output

%%% write measurement data to HDF5
writedata(handles, data)

%%% write temporary pipeline data to HDF5
writeoutputargs(handles, output_args)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
