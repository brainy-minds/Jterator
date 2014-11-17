#!/usr/local/bin/mscript

import jterator.api.io.*;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% jterator input

fprintf(sprintf('jt - %s:\n', mfilename));

%%% read "standard" input
handles_stream = input('', 's')

%%% retrieve handles from .YAML files
handles = get_handles(handles_stream);

%%% read input arguments from .HDF5 files
input_args = read_input_args(handles);

%%% check whether input arguments are valid
input_args = check_input_args(input_args);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% ------------------------------------------------------------------------
%% ---------------------------- module specific ---------------------------

%%%%%%%%%%%%%%%%%%%%
%% input handling %%
%%%%%%%%%%%%%%%%%%%%

ImagePath = input_args.ImageDirectory;
ImageFilename = input_args.ImageFilename;
StatsPath = input_args.StatsDirectory;
StatsFilename = input_args.StatsFilename;


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

output_args = struct();

output_tmp = struct();
output_tmp.OrigImage = OrigImage;
output_tmp.StatsMeanImage = MeanImage;
output_tmp.StatsStdImage = StdImage;

%% ---------------------------- module specific ---------------------------
%% ------------------------------------------------------------------------


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% jterator output

%%% create .HDF5 file
build_hdf5(handles);

%%% save loaded data in .HDF5 file
write_output_args(handles, output_args);
write_output_tmp(handles, output_tmp);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
