import jterator.api.io.*;
import json.*;

%%% redirect standard output to log file
fid = fopen(sprintf('../logs/%s.output', mfilename), 'w');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% jterator input

fprintf(fid, sprintf('jt - %s:\n', mfilename));

%%% read "standard" input
handles_filename = input('','s');

%%% retrieve handles from .YAML files
handles = get_handles(handles_filename, fid);

%%% retrieve initial values from handles
values = read_input_values(handles, fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% ------------------------------------------------------------------------
%% ---------------------------- module specific ---------------------------

%%%%%%%%%%%%%%%%%%%%
%% input handling %%
%%%%%%%%%%%%%%%%%%%%

ImagePath = values.ImageDirectory;
ImageFilename = values.ImageFilename;
StatsPath = values.StatsDirectory;
StatsFilename = values.StatsFilename;


%%%%%%%%%%%%%%%%
%% processing %%
%%%%%%%%%%%%%%%%

%%% load primary raw data from disk (in this test scenario this is an image)
% for original intensity images
OrigImage = double(imread(fullfile(ImagePath, ImageFilename)));
% for illumination correction statistics
structStats = load(fullfile(StatsPath, StatsFilename));
MeanImage = double(structStats.stat_values.mean);
StdImage = double(structStats.stat_values.std);


%%%%%%%%%%%%%%%%%%%%
%% prepare output %%
%%%%%%%%%%%%%%%%%%%%

%%% structure output arguments for later storage in the .HDF5 file
output_args = struct();
output_args.OrigImage = OrigImage;
output_args.StatsMeanImage = MeanImage;
output_args.StatsStdImage = StdImage;

%% ---------------------------- module specific ---------------------------
%% ------------------------------------------------------------------------


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% jterator output

%%% create .HDF5 file
build_hdf5(handles, fid);

%%% save loaded data in .HDF5 file
write_output_args(handles, output_args, fid);

fclose(fid);

%%% write "temporary" pipeline data to standard output as JSON
fprintf(savejson('', structStats))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
