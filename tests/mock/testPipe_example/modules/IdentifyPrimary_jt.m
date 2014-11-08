import jterator.api.io.*;


fprintf('jt - %s:\n', mfilename) 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% jterator input

%%% "standard" input
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

figure, imagesc(PrimaryObjects)

%%% save figure als PDF
if strcmpi(saveFigure, 'Yes')
    strFigureName = sprintf('Figure_Module_%s',mfilename);
    strPDFPath = strrep(os.path.dirname(which(mfilename)), 'modules', 'figures');
    gcf2pdf(strPDFPath, strFigureName);
end


%%%%%%%%%%%%%%%%%%%%
%% prepare output %%
%%%%%%%%%%%%%%%%%%%%

%%% structure output arguments for later storage in the .HDF5 file
output_args = struct();
output_args.Nuclei = PrimaryObjects;

%% ---------------------------- module specific ---------------------------
%% ------------------------------------------------------------------------


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% jterator output

write_output_args(handles, output_args);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
