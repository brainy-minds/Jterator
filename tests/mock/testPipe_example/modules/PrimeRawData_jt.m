#!/usr/bin/Mscript

import jterator.api.io.*;
import json.*;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% jterator input

fprintf(sprintf('jt - %s:\n', mfilename));

%%% read "standard" input
handles_stream = fopen(0, 'r');

%%% retrieve handles from .YAML files
handles = get_handles(handles_stream);

%%% retrieve initial values from handles
values = read_input_values(handles);

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
