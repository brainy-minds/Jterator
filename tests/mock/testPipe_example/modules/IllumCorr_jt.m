import jterator.api.io.*;


%%% redirect standard output to log file
fid = fopen(sprintf('../logs/%s.output', mfilename), 'w');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% jterator input

fprintf(fid, sprintf('jt - %s:\n', mfilename));

%%% read "standard" input
handles_filename = input('','s');

%%% retrieve handles from .YAML files
handles = get_handles(handles_filename, fid);

%%% read input arguments from .HDF5 files
input_args = read_input_args(handles, fid);

%%% check whether input arguments are valid
input_args = check_input_args(input_args, fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% ------------------------------------------------------------------------
%% ---------------------------- module specific ---------------------------

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


%%%%%%%%%%%%%%%%%
%% make figure %%
%%%%%%%%%%%%%%%%%

%%% make figure
fig = figure, imagesc(CorrImage);

%%% save figure as PDF file
set(fig, 'PaperPosition', [0 0 7 7], 'PaperSize', [7 7]);
saveas(fig, sprintf('figures/%s', mfilename), 'pdf');

%%% send figure to plotly
% fig2plotly() 


%%%%%%%%%%%%%%%%%%%%
%% prepare output %%
%%%%%%%%%%%%%%%%%%%%

%%% structure output arguments for later storage in the .HDF5 file
output_args = struct();
output_args.CorrImage = CorrImage;

%% ---------------------------- module specific ---------------------------
%% ------------------------------------------------------------------------


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% jterator output

write_output_args(handles, output_args, fid);

fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
