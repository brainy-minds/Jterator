#!/usr/local/bin/mscript

import jterator.api.io.*;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% jterator input

fprintf(sprintf('jt - %s:\n', mfilename));

%%% read "standard" input
handles_filename = input('','s');

%%% retrieve handles from .YAML files
handles = get_handles(handles_filename);

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


%%%%%%%%%%%%%%%%
%% processing %%
%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%
%% make figure %%
%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%
%% prepare output %%
%%%%%%%%%%%%%%%%%%%%

output_args = struct();
output_tmp = struct();

%% ---------------------------- module specific ---------------------------
%% ------------------------------------------------------------------------


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% jterator output

%%% write output data to HDF5
write_output_args(handles, output_args);
write_output_tmp(handles, output_tmp;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
