import jterator.*;
import subfunctions.*;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% jterator input

fprintf(sprintf('jt - %s:\n', mfilename));

%%% read standard input
handles_stream = input_stream;

%%% change current working directory
cd(currentDirectory)

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

%%% Input arguments for identifying objects by intensity threshold
ThresholdCorrection = input_args.ThresholdCorrection;
ThresholdMethod = input_args.ThresholdMethod;
ThresholdRange = input_args.ThresholdRange;
pObject = input_args.pObject;
doSmooth = input_args.doSmooth;
SmoothingMethod = input_args.SmoothingMethod;
SmoothingFilterSize = input_args.SmoothingFilterSize;

%%% Input arguments for cutting clumped objects
CuttingPasses = input_args.CuttingPasses;
FilterSize = input_args.FilterSize;
SlidingWindow = input_args.SlidingWindow;
CircularSegment = input_args.CircularSegment;
MaxConcaveRadius = input_args.MaxConcaveRadius;
MaxArea = input_args.MaxArea;
MaxSolidity = input_args.MaxSolidity;
MinArea = input_args.MinArea;
MinCutArea = input_args.MinCutArea;
MinFormFactor = input_args.MinFormFactor;

%%% Input arguments for plotting segmentation results
doPlot = input_args.doPlot;
doTestModePerimeter = input_args.doTestModePerimeter;
doTestModeShape = input_args.doTestModeShape;

%%% Input arguments for saving segmentation images
doSaveSegmentedImage = input_args.doSaveSegmentedImage;
OrigImageFilename = input_args.OrigImageFilename;
SegmentationPath = input_args.SegmentationPath;


%%%%%%%%%%%%%%%%
%% processing %%
%%%%%%%%%%%%%%%%

%% Threshold image
MinimumThreshold = ThresholdRange(1);
MaximumThreshold = ThresholdRange(2);

%%% Normalize image intensities a la CellProfiler
NormImage = InputImage ./ 2^16;

%%% Calculate threshold
threshhold = ImageThreshold(ThresholdMethod, ...
                            pObject, ...
                            MinimumThreshold, ...
                            MaximumThreshold, ...
                            ThresholdCorrection, ...
                            NormImage, ...
                            []);

%%% Threshold intensity image to detect objects
ThreshImage = zeros(size(NormImage), 'double');
ThreshImage(NormImage > threshhold) = 1;

%%% Fill holes in objects
FillImage = imfill(double(ThreshImage),'holes');


%% Cut clumped objects:
if ~isempty(FillImage)
    
    %------------------------------------------
    % Select objects in input image for cutting
    %------------------------------------------
    
    ObjectsCut = zeros([size(FillImage),CuttingPasses]);
    ObjectsNotCut = zeros([size(FillImage),CuttingPasses]);
    SelectedObjects = zeros([size(FillImage),CuttingPasses]);
    CutMask = zeros([size(FillImage),CuttingPasses]);
        
    for i = 1:CuttingPasses
        
        if i==1
            Objects = FillImage;
        else
            Objects = ObjectsCut(:,:,i-1);
        end
        
        %%% Select objects for cutting
        thresholds = struct();
        thresholds.Solidity = MaxSolidity;
        thresholds.FormFactor = MinFormFactor;
        thresholds.UpperSize = MaxArea;
        thresholds.LowerSize = MinArea;
        [SelectedObjects(:,:,i), Objects2Cut, ObjectsNotCut(:,:,i)] = SelectObjects(Objects, thresholds);
        
        
        %------------
        % Cut objects
        %------------
        
        %%% Smooth image to avoid problems with bwtraceboundary.m
        SmoothDisk = getnhood(strel('disk', FilterSize, 0));
        Objects2Cut = bwlabel(imdilate(imerode(Objects2Cut, SmoothDisk), SmoothDisk));
        
        %%% Separate clumped objects along watershed lines

        % PerimeterAnalysis currently cannot handle holes in objects (we may
        % want to implement this in case of big clumps of many objects).
        % Sliding window size is linked to object size. Small object sizes
        % (e.g. in case of images acquired with low magnification) limits
        % maximal size of the sliding window and thus sensitivity of the
        % perimeter analysis.
        
        SelectionMethod = 'quickNdirty'; %'niceNslow'
        PerimSegAngMethod = 'best_inline';
        
        %%% Perform perimeter analysis
        PerimeterProps = PerimeterAnalysis(Objects2Cut, SlidingWindow);
        
        %%% Perform the actual segmentation        
        CutMask(:,:,i) = PerimeterWatershedSegmentation(Objects2Cut, ...
                                                    NormImage, ...
                                                    PerimeterProps, ...
                                                    MaxConcaveRadius, ...
                                                    CircularSegment, ...
                                                    MinCutArea, ...
                                                    PerimSegAngMethod, ...
                                                    SelectionMethod);
        ObjectsCut(:,:,i) = bwlabel(Objects2Cut .* ~CutMask(:,:,i));
        
    end
    
    %----------------------------------------------
    % Combine objects from different cutting passes
    %----------------------------------------------
    
    AllCut = logical(sum(ObjectsCut, 3));
    
    if ~isempty(AllCut)
        imErodeMask = bwmorph(AllCut, 'shrink', inf);
        imDilatedMask = IdentifySecPropagateSubfunction(double(imErodeMask), ...
                                                        InputImage, ...
                                                        AllCut, ...
                                                        1);
    end
    
    %%% Retrieve objects that were not cut
    AllNotCut = logical(sum(ObjectsNotCut, 3));
    IdentifiedNuclei = bwlabel(logical(AllCut + AllNotCut));

else

    IdentifiedNuclei = bwlabel(zeros(size(FillImage)));
     
end

% TODO: calculate centroids and store them together with the object ids


%%%%%%%%%%%%%%%%%%%%%
%% display results %%
%%%%%%%%%%%%%%%%%%%%%

        
if doPlot

    %%% Create overlay image
    B = bwboundaries(AllCut, 'holes');
    imCutShapeObjectsLabel = label2rgb(bwlabel(AllCut),'jet','k','shuffle');
    
    %%% Make figure
    AllSelected = SelectedObjects(:,:,1);
    fig = figure;
    subplot(2,2,2), imagesc(logical(AllSelected==1)),
    title('Cut lines on selected original objects');
    hold on
    white = cat(3, ones(size(AllSelected)), ones(size(AllSelected)), ones(size(AllSelected)));
    h = imagesc(white);
    set(h, 'AlphaData', logical(sum(CutMask, 3)))
    hold off
    freezeColors
    subplot(2,2,1), imagesc(AllSelected), colormap('jet'),
    title('Selected original objects');
    freezeColors
    subplot(2,2,3), imagesc(NormImage),
    title('Outlines of separated objects');
    hold on
    for k = 1:length(B)
        boundary = B{k};
        plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 1)
    end
    hold off
    freezeColors
    subplot(2,2,4), imagesc(imCutShapeObjectsLabel),
    title('Separated objects');
    freezeColors

    %%% Save figure as pdf
    set(fig, 'PaperPosition', [0 0 7 7], 'PaperSize', [7 7]);
    saveas(fig, sprintf('figures/%s', mfilename), 'pdf');

    p = fig2plotly(fig);

end


%%%%%%%%%%%%%%%%%%
%% save results %%
%%%%%%%%%%%%%%%%%%

if doSaveSegmentedImage
    SegmentationFilename = strrep(os.path.basename(OrigImageFilename'), ...
                                  '.png', '_segmentedNuclei.png');
    SegmentationFilename = fullfile(SegmentationPath, SegmentationFilename);
    if ~isdir(SegmentationPath)
        mkdir(SegmentationPath)
    end
    imwrite(IdentifiedNuclei, SegmentationFilename);
    fprintf('%s: Segmented ''nuclei'' were saved to file: "%s"\n', ...
            mfilename, SegmentationFilename)
end


%%%%%%%%%%%%%%%%%%%%
%% prepare output %%
%%%%%%%%%%%%%%%%%%%%

%%% Structure output arguments for later storage in the .HDF5 file
data = struct();

output_args = struct();
output_args.Nuclei = IdentifiedNuclei;

%% ---------------------------- module specific ---------------------------
%% ------------------------------------------------------------------------


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% jterator output

%%% write measurement data to HDF5
writedata(handles, data);

%%% write temporary pipeline data to HDF5
writeoutputargs(handles, output_args);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
