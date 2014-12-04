import jterator.api.io.*;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% jterator input

fprintf('jt - %s:\n', mfilename);

%%% read "standard" input
handles_stream = input('','s');

%%% retrieve handles from .YAML files
handles = gethandles(handles_stream);

%%% read input arguments from .HDF5 files
input_args = readinputargs(handles);

%%% check whether input arguments are valid
input_args = checkinputargs(input_args);

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
saveas(fig, sprintf('../figures/%s', mfilename), 'pdf');

%%% send figure to plotly
% fig2plotly() 


%%%%%%%%%%%%%%%%%%%%
%% prepare output %%
%%%%%%%%%%%%%%%%%%%%

output_args = struct();

output_tmp = struct();
output_tmp.CorrImage = CorrImage;

%% ---------------------------- module specific ---------------------------
%% ------------------------------------------------------------------------


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% jterator output

writeoutputargs(handles, output_args);
writeoutputtmp(handles, output_tmp);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
