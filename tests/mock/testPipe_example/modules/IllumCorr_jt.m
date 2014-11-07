import jterator.api.io.*;


fprintf('jt - %s:\n', mfilename) 

handles_stream = input('','s');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% jterator input

%%% retrieve handles from .JSON files
handles = get_handles(handles_stream);

%%% read input arguments from .HDF5 files
input_args = read_input_args(handles);

%%% check whether input arguments are valid
input_args = check_input_args(input_args);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% ------------------------------------------------------------------------
% ---------------------------- module specific ----------------------------

%%%%%%%%%%%%%%%%%%%%
%% input handling %%
%%%%%%%%%%%%%%%%%%%%

OrigImage = input_args.OrigImage;
MeanImage = input_args.StatsMeanImage;
StdImage = input_args.StatsStdImage;


%%%%%%%%%%%%%%%%
%% processing %%
%%%%%%%%%%%%%%%%

%%% correct intensity image for illumination artefact
% Avoid -Inf values after log10 transform.
OrigImage(OrigImage == 0) = 1;
% Apply z-score normalization for each single pixel.
CorrImage = (log10(OrigImage) - MeanImage) ./ StdImage;
% Reverse z-score.
CorrImage = (CorrImage .* mean(StdImage(:))) + mean(MeanImage(:));
% Reverse log10 transform that was applied to images when learning 
% mean/std statistics as well the corrected image.
CorrImage = 10 .^ CorrImage;


%%%%%%%%%%%%%%%%%%%%
%% prepare output %%
%%%%%%%%%%%%%%%%%%%%

%%% structure output arguments for later storage in the .HDF5 file
output_args = struct();
output_args.CorrImage = CorrImage;

% ---------------------------- module specific ----------------------------
%% ------------------------------------------------------------------------


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% jterator output

write_output_args(handles, output_args);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
