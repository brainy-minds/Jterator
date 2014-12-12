import jterator.api.io.*;
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
ThresholdMethod = input_args.ThresholdMethod;
ThresholdRange = input_args.ThresholdRange;
ThresholdCorrection = input_args.ThresholdCorrection;
pObject = input_args.pObject;
saveFigure = input_args.saveFigure;


%%%%%%%%%%%%%%%%
%% processing %%
%%%%%%%%%%%%%%%%


%% Threshold image:

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
    
    %-------------------------------------------
    % Select objects in input image for cutting
    %-------------------------------------------
    
    imObjects = zeros([size(imInputObjects),CuttingPasses]);
    SelectedObjects = zeros([size(imInputObjects),CuttingPasses]);
    imCutMask = zeros([size(imInputObjects),CuttingPasses]);
    imCut = zeros([size(imInputObjects),CuttingPasses]);
    ObjectsNot2Cut = zeros([size(imInputObjects),CuttingPasses]);
    objFormFactor = cell(CuttingPasses,1);
    objSolidity = cell(CuttingPasses,1);
    objArea = cell(CuttingPasses,1);
    cellPerimeterProps = cell(CuttingPasses,1);
    
    for i = 1:CuttingPasses
        
        if i==1
            imObjects(:,:,i) = imInputObjects;
        else
            imObjects(:,:,i) = imCut(:,:,i-1);
        end
        
        %%% Select objects for cutting
        thresholds = struct();
        thresholds.Solidity = SolidityThres;
        thresholds.FormFactor = FormFactorThres;
        thresholds.UpperSize = UpperSizeThres;
        thresholds.LowerSize = LowerSizeThres;
        [SelectedObjects(:,:,i), Objects2Cut(:,:,i), ObjectsNot2Cut(:,:,i)] = SelectObjects(Objects, thresholds);
        
        
        %-------------
        % Cut objects
        %-------------
        
        %%% Smooth image
        SmoothDisk = getnhood(strel('disk',smoothingDiskSize,0));%minimum that has to be done to avoid problems with bwtraceboundary
        Objects2Cut = bwlabel(imdilate(imerode(Objects2Cut,SmoothDisk),SmoothDisk));
        
        % Separate clumped objects along watershed lines
        %WindowSizeHoles = 4;
        % PerimeterAnalysis currently cannot handle holes in objects (we may
        % want to implement this in case of big clumps of many objects).
        % Sliding window size is linked to object size. Small object sizes
        % (e.g. in case of images acquired with low magnification) limits
        % maximal size of the sliding window and thus sensitivity of the
        % perimeter analysis.
        
        SelectionMethod = 'quickNdirty'; %'niceNslow'
        PerimSegAngMethod = 'best_inline';
        
        %%% Perform perimeter analysis
        cellPerimeterProps{i} = PerimeterAnalysis(Objects2Cut, ...
                                                  WindowSize);
        
        %%% Perform the actual segmentation
        imCutMask(:,:,i) = PerimeterWatershedSegmentation(Objects2Cut, ...
                                                          OrigImage, ...
                                                          cellPerimeterProps{i}, ...
                                                          PerimSegEqRadius, ...
                                                          PerimSegEqSegment, ...
                                                          LowerSizeThres2, ...
                                                          PerimSegAngMethod, ...
                                                          SelectionMethod);
        imCut(:,:,i) = bwlabel(Objects2Cut .* ~imCutMask(:,:,i));
        
        
        %------------------------------
        % Display intermediate results
        %------------------------------
        
        if doSaveFigure
        
            % Create overlay images
            imOutlineShapeSeparatedOverlay = OrigImage;
            B = bwboundaries(imCut(:,:,i),'holes');
            imCutShapeObjectsLabel = label2rgb(bwlabel(imCut(:,:,i)),'jet','k','shuffle');
            
            % GUI
            tmpSelected = (SelectedObjects(:,:,i));
            ThisModuleFigureNumber = handles.Current.(['FigureNumberForModule',CurrentModule]);
            CPfigure(handles,'Image',ThisModuleFigureNumber);
            subplot(2,2,2), CPimagesc(logical(tmpSelected==1),handles),
            title(['Cut lines on selected original objects, cycle # ',num2str(handles.Current.SetBeingAnalyzed)]);
            hold on
            red = cat(3, ones(size(tmpSelected)), zeros(size(tmpSelected)), zeros(size(tmpSelected)));
            h = imagesc(red);
            set(h, 'AlphaData', logical(imCutMask(:,:,i)))
            hold off
            freezeColors
            subplot(2,2,1), CPimagesc(SelectedObjects(:,:,i),handles), colormap('jet'),
            title(['Selected original objects, cycle # ',num2str(handles.Current.SetBeingAnalyzed)]);
            freezeColors
            subplot(2,2,3), CPimagesc(imOutlineShapeSeparatedOverlay,handles),
            title(['Outlines of seperated objects, cycle # ',num2str(handles.Current.SetBeingAnalyzed)]);
            hold on
            for k = 1:length(B)
                boundary = B{k};
                plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 1)
            end
            hold off
            freezeColors
            subplot(2,2,4), CPimagesc(imCutShapeObjectsLabel,handles),
            title(['Seperated objects, cycle # ',num2str(handles.Current.SetBeingAnalyzed)]);
            freezeColors

        end
        
    end
    
    %-----------------------------------------------
    % Combine objects from different cutting passes
    %-----------------------------------------------
    
    imCut = logical(imCut(:,:,CuttingPasses));
    
    if ~isempty(imCut)
        imErodeMask = bwmorph(imCut,'shrink',inf);
        imDilatedMask = IdentifySecPropagateSubfunction(double(imErodeMask),OrigImage,imCut,1);
    end
    
    ObjectsNot2Cut = logical(sum(ObjectsNot2Cut,3));% Retrieve objects that were not cut
    imFinalObjects = bwlabel(logical(imDilatedMask + ObjectsNot2Cut));
    
else
    
    cellPerimeterProps = {};
    imFinalObjects = zeros(size(imInputObjects));
    imObjects = zeros([size(imInputObjects),CuttingPasses]);
    SelectedObjects = zeros([size(imInputObjects),CuttingPasses]);
    imCutMask = zeros([size(imInputObjects),CuttingPasses]);
    imCut = zeros([size(imInputObjects),CuttingPasses]);
    ObjectsNot2Cut = zeros([size(imInputObjects),CuttingPasses]);
    objFormFactor = cell(CuttingPasses,1);
    objSolidity = cell(CuttingPasses,1);
    objArea = cell(CuttingPasses,1);
    cellPerimeterProps = cell(CuttingPasses,1);
    
end

%%% label detected objects
PrimaryObjects = bwlabel(FillImage);


%%%%%%%%%%%%%%%%%
%% make figure %%
%%%%%%%%%%%%%%%%%

%%% save figure als PDF
if saveFigure
    fig = figure, imagesc(PrimaryObjects);
    set(fig, 'PaperPosition', [0 0 7 7], 'PaperSize', [7 7]);
    saveas(fig, sprintf('figures/%s', mfilename), 'pdf');
end


%%%%%%%%%%%%%%%%%%%%
%% prepare output %%
%%%%%%%%%%%%%%%%%%%%

%%% structure output arguments for later storage in the .HDF5 file
data = struct();

output_args = struct();
output_args.Nuclei = PrimaryObjects;

%% ---------------------------- module specific ---------------------------
%% ------------------------------------------------------------------------


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% jterator output

%%% write measurement data to HDF5
writedata(handles, data);

%%% write temporary pipeline data to HDF5
writeoutputtmp(handles, output_args);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
