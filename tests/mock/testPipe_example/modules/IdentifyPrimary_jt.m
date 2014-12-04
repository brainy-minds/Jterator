import jterator.api.io.*;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% jterator input

fprintf(sprintf('jt - %s:\n', mfilename));

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

InputImage = input_args.CorrImage;
ThresholdMethod = input_args.ThresholdMethod;
ThresholdRange = input_args.ThresholdRange;
ThresholdCorrection = input_args.ThresholdCorrection;
pObject = input_args.pObject;
saveFigure = input_args.saveFigure;


%%%%%%%%%%%%%%%%
%% processing %%
%%%%%%%%%%%%%%%%

MinimumThreshold = ThresholdRange(1);
MaximumThreshold = ThresholdRange(2);

%%% normalize image intensities a la CellProfiler
NormImage = InputImage ./ 2^16;

%%% calculate threshold
threshhold = JTthreshold(ThresholdMethod, pObject, ...
                          MinimumThreshold, MaximumThreshold, ...
                          ThresholdCorrection, NormImage, []);

%%% threshold intensity image to detect objects
ThreshImage = zeros(size(NormImage), 'double');
ThreshImage(NormImage > threshhold) = 1;

%%% fill holes in objects
FillImage = imfill(double(ThreshImage),'holes');

%%% label detected objects
PrimaryObjects = bwlabel(FillImage);

%%%%%%%%%%%%%%%%%
%% make figure %%
%%%%%%%%%%%%%%%%%

%%% save figure als PDF
if saveFigure
    fig = figure, imagesc(PrimaryObjects);
    set(fig, 'PaperPosition', [0 0 7 7], 'PaperSize', [7 7]);
    saveas(fig, sprintf('../figures/%s', mfilename), 'pdf');
end


%%%%%%%%%%%%%%%%%%%%
%% prepare output %%
%%%%%%%%%%%%%%%%%%%%

%%% structure output arguments for later storage in the .HDF5 file
output_args = struct();

output_tmp = struct();
output_tmp.Nuclei = PrimaryObjects;

%% ---------------------------- module specific ---------------------------
%% ------------------------------------------------------------------------


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% jterator output

writeoutputargs(handles, output_args);
writeoutputtmp(handles, output_tmp);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
