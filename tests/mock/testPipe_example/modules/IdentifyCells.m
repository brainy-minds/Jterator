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

NucleiImage = input_args.NucleiImage;
CelltraceImage = input_args.CelltraceImage;

doSmooth = input_args.doSmooth;
SmoothingMethod = input_args.SmoothingMethod;
SmoothingFilterSize = input_args.SmoothingFilterSize;

CorrectionFactors = input_args.CorrectionFactors;
LowerUpperBounds = input_args.CorrectionFactors;


%%%%%%%%%%%%%%%%
%% processing %%
%%%%%%%%%%%%%%%%


%%% Chooses the first word of the method name (removing 'Global' or 'Adaptive').
ThresholdMethod = strtok(iThreshold);
%%% Checks if a custom entry was selected for Threshold, which means we are using an incoming binary image rather than calculating a threshold.
if isempty(strmatch(ThresholdMethod,{'Otsu','MoG','Background','RobustBackground','RidlerCalvard','All','Set'},'exact'))
   %if ~(strncmp(Threshold,'Otsu',4) || strncmp(Threshold,'MoG',3) || strfind(Threshold,'Background') ||strncmp(Threshold,'RidlerCalvard',13) || strcmp(Threshold,'All') || strcmp(Threshold,'Set interactively'))
   if isnan(str2double(iThreshold))
       GetThreshold = 0;
       BinaryInputImage = CPretrieveimage(handles,iThreshold,ModuleName,'MustBeGray','CheckScale');
   else
       GetThreshold = 1;
   end
else
   GetThreshold = 1;
end

%%% Checks that the Min and Max threshold bounds have valid values
index = strfind(ThresholdRange,',');
if isempty(index)
   error(['Image processing was canceled in the ', ModuleName, ' module because the Min and Max threshold bounds are invalid.'])
end

MinimumThreshold = str2double(ThresholdRange(1:index-1));
MaximumThreshold = str2double(ThresholdRange(index+1:end));

% Create vector containing the thresholds that should be tested
[isSafe, iThresholdCorrection]= inputVectorsForEvalCP3D(iThresholdCorrection,false);
if isSafe == false
   error(['Image processing was canceled in the ', ModuleName, ' module because input of threshold contained forbidden characters'])
else
   ThresholdCorrection = eval(iThresholdCorrection);
end



%%%%%%%%%%%%%%%%%%%%%%
%%% IMAGE ANALYSIS %%%
%%%%%%%%%%%%%%%%%%%%%%
drawnow
numThresholdsToTest = length(ThresholdCorrection);
ThresholdArray = cell(numThresholdsToTest,1); % [modified by TS to include multiple thrsholds]

%obtain first threshold via CPthreshold. note that this will also create a
%threshold measuremnt, this measuremnt will not be produced for sequential
%thresholds to prevent over/writing and conflicts that arise if
%numThreshold>=3
if GetThreshold
   % [TS] force to use minimal treshold value of 0 and maximum of 1, to ensure
   % equal thresholding for all tested tresholds
   [handles,ThresholdArray{1}] = CPthreshold(handles,iThreshold,pObject,'0','1',ThresholdCorrection(1),CelltraceImage,ImageName,ModuleName,SecondaryObjectName);
else
   ThresholdArray{1} = 0; % should never be used
end

%%%% [TS] start modification for obtaining multiple thresholds %%%%%%%%%%%%%%%%%
if numThresholdsToTest>1
   for k=2:numThresholdsToTest
       %%% STEP 1a: Marks at least some of the background
       if GetThreshold
           refThreshold = ThresholdArray{1};
           ThresholdArray{k} = refThreshold .* ThresholdCorrection(k) ./ThresholdCorrection(1);
       else
           ThresholdArray{k} = 0; % should never be used
       end
   end
end

% now fix thresholds outside of range. Could be made nicer by direcly
% calling a function for fixing thresholds for CP standard case (k=1) and
% [TS] modification for k>=2
for k=1:numThresholdsToTest
   % note that CP adresses the threshold in such a way that it could be
   % either a number or a matrix.-> the internally generated threshold
   % might be either of it. The following lines should support both.
   reconstituteThresholdImage = ThresholdArray{k};
   bnSomethingOutsidRange = false;

   f = reconstituteThresholdImage(:) < MinimumThreshold;
   if any(f)
       reconstituteThresholdImage(f) = MinimumThreshold;
       bnSomethingOutsidRange = true;
   end

   f = reconstituteThresholdImage(:) > MaximumThreshold;
   if any(f)
       reconstituteThresholdImage(f) = MaximumThreshold;
       bnSomethingOutsidRange = true;
   end

   if bnSomethingOutsidRange == true
       ThresholdArray{k} = reconstituteThresholdImage;
   end
end

%%%% [TS] end modification for obtaining multiple thresholds %%%%%%%%%%%%%%%%%


%%%% [TS] Start modification> DISMISS only border %%%%%%%%%%%%%%%%%%%%%%
%%% Preliminary objects, which were not identified as object proper, still
%%% serve as seeds for allocating pixels to secondary object. While this
%%% makes sense for nuclei, which were discared in the primary module due to
%%% their location at the image border (and have a surrounding cytoplasm),
%%% it can lead to wrong segmenations, if a false positive nucleus, that was
%%% filtered away , eg. by the DiscardSinglePixel... module , was present

%%% corrsponds to one line from STEP 10, moved up. Allows proper
%%% initialzing for reconstitution
%%% Converts the EditedPrimaryBinaryImage to binary.
EditedPrimaryBinaryImage = im2bw(NucleiImage,.5);

% Replace the way the mask PrelimPrimaryBinaryImage is generated
%%% Use a shared line from STEP 0. This will allow proper initializing for reconstitution.
%%% Converts the NucleiImage to binary.
%%% OLD> PrelimPrimaryBinaryImage = im2bw(NucleiImage,.5);

%%% Get IDs of objects at image border
R= NucleiImage([1 end],:);
C= NucleiImage(:,[1 end]);
BoderObjIDs = unique([R C']);
while any(BoderObjIDs==0)
   BoderObjIDs = BoderObjIDs(2:end);
end
clear R; clear C;

PrelimPrimaryBinaryImage = false(size(EditedPrimaryBinaryImage));

f =     ismember(NucleiImage,BoderObjIDs) | ... % objects at border
   EditedPrimaryBinaryImage;            % proper objects

PrelimPrimaryBinaryImage(f) = true;


%%%% [TS] End modification> DISMISS only border %%%%%%%%%%%%%%%%%%%%%




%%%% [TS] %%%%%%%%%%%%% Start of SHARED code for precalculations %%%%%%%%%%%
% note that fragments of original function were replaced by TS to prevent
% redundant calculations

drawnow

%%% Creates the structuring element that will be used for dilation.
StructuringElement = strel('square',3);
%%% Dilates the Primary Binary Image by one pixel (8 neighborhood).
DilatedPrimaryBinaryImage = imdilate(PrelimPrimaryBinaryImage, StructuringElement);
%%% Subtracts the PrelimPrimaryBinaryImage from the DilatedPrimaryBinaryImage,
%%% which leaves the PrimaryObjectOutlines.
PrimaryObjectOutlines = DilatedPrimaryBinaryImage - PrelimPrimaryBinaryImage;


%%% STEP 4: Calculate the Sobel image, which reflects gradients, which will
%%% be used for the watershedding function.
drawnow
%%% Calculates the 2 sobel filters.  The sobel filter is directional, so it
%%% is used in both the horizontal & vertical directions and then the
%%% results are combined.
filter1 = fspecial('sobel');
filter2 = filter1';
%%% Applies each of the sobel filters to the original image.
I1 = imfilter(CelltraceImage, filter1);
I2 = imfilter(CelltraceImage, filter2);
%%% Adds the two images.
%%% The Sobel operator results in negative values, so the absolute values
%%% are calculated to prevent errors in future steps.
AbsSobeledImage = abs(I1) + abs(I2);
clear I1; clear I2;                  %%% [NB] hack. save memory

%%%% [TS] %%%%%%%%%%%%% End of SHARED code for precalculations %%%%%%%%%%%


%%%%%% [TS] %%%%%%%%%%%%%%%  ITERATION CODE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% intialize output

cellFinalLabelMatrixImage = cell(numThresholdsToTest,1);


for k=1:numThresholdsToTest

   % STEP 0
   %%% Thresholds the original image.
   if GetThreshold
       ThresholdedOrigImage = CelltraceImage > ThresholdArray{k};
   else
       ThresholdedOrigImage = logical(BinaryInputImage);
   end


   %%% STEP 1b: Marks at least some of the background

   %%% Inverts the image.
   InvertedThresholdedOrigImage = imcomplement(ThresholdedOrigImage);
   clear ThresholdedOrigImage;             %%% [NB] hack. save memory.

   %%% STEP 3: Produce the marker image which will be used for the first
   %%% watershed.
   drawnow
   %%% Combines the foreground markers and the background markers.
   BinaryMarkerImagePre = PrelimPrimaryBinaryImage | InvertedThresholdedOrigImage;
   %%% Overlays the PrimaryObjectOutlines to maintain distinctions between each
   %%% primary object and the background.
   BinaryMarkerImage = BinaryMarkerImagePre;
   clear BinaryMarkerImagePre;             %%% [NB] hack. save memory.
   BinaryMarkerImage(PrimaryObjectOutlines == 1) = 0;


   %%% STEP 5: Perform the first watershed.
   drawnow

   %%% Overlays the foreground and background markers
   Overlaid = imimposemin(AbsSobeledImage, BinaryMarkerImage);
   clear BinaryMarkerImage;  %%% [NB] hack. save memory.

   %%% Perform the watershed on the marked absolute-value Sobel Image.
   BlackWatershedLinesPre = watershed(Overlaid);
   clear Overlaid;                 %%% [NB] hack. save memory.

   %%% Bug workaround (see step 9).
   %%% [NB, WATERSHED BUG IN VERSION 2011A (Windows only) OR HIGHER HAS BEEN FIXED. SO CHECK VERSION FIRST]
   if verLessThan('matlab', '7.12.0') && ispc()
       BlackWatershedLinesPre2 = im2bw(BlackWatershedLinesPre,.5);
       BlackWatershedLines = bwlabel(BlackWatershedLinesPre2);
       %%% [NB] hack. save memory.
       clear BlackWatershedLinesPre2 BlackWatershedLinesPre;
   else
       %%% [BS, QUICK AND DIRTY HACK FROM PEKLMANS]
       BlackWatershedLines = double(BlackWatershedLinesPre);
       %%% [NB] hack. save memory.
       clear BlackWatershedLinesPre;
       %%% END OF BS-HACK BUGFIX FOR VERSION 2011 AND LATER?
   end

   %%% STEP 6: Identify and extract the secondary objects, using the watershed
   %%% lines.
   drawnow
   %%% The BlackWatershedLines image is a label matrix where the watershed
   %%% lines = 0 and each distinct object is assigned a number starting at 1.
   %%% This image is converted to a binary image where all the objects = 1.
   SecondaryObjects1 = im2bw(BlackWatershedLines,.5);
   %%% [NB] hack. save memory.
   clear BlackWatershedLines;
   %%% Identifies objects in the binary image using bwlabel.
   %%% Note: Matlab suggests that in some circumstances bwlabeln is faster
   %%% than bwlabel, even for 2D images.  I found that in this case it is
   %%% about 10 times slower.
   LabelMatrixImage1 = bwlabel(SecondaryObjects1,4);
   %%% [NB] hack. save memory.
   clear SecondaryObjects1;
   drawnow

   %%% STEP 7: Discarding background "objects".  The first watershed function
   %%% simply divides up the image into regions.  Most of these regions
   %%% correspond to actual objects, but there are big blocks of background
   %%% that are recognized as objects. These can be distinguished from actual
   %%% objects because they do not overlap a primary object.

   %%% The following changes all the labels in LabelMatrixImage1 to match the
   %%% centers they enclose (from PrelimPrimaryBinaryImage), and marks as background
   %%% any labeled regions that don't overlap a center. This function assumes
   %%% that every center is entirely contained in one labeled area.  The
   %%% results if otherwise may not be well-defined. The non-background labels
   %%% will be renumbered according to the center they enclose.

   %%% Finds the locations and labels for different regions.
   area_locations = find(LabelMatrixImage1);
   area_labels = LabelMatrixImage1(area_locations);
   %%% Creates a sparse matrix with column as label and row as location,
   %%% with the value of the center at (I,J) if location I has label J.
   %%% Taking the maximum of this matrix gives the largest valued center
   %%% overlapping a particular label.  Tacking on a zero and pushing
   %%% labels through the resulting map removes any background regions.
   map = [0 full(max(sparse(area_locations, area_labels, PrelimPrimaryBinaryImage(area_locations))))];

   ActualObjectsBinaryImage = map(LabelMatrixImage1 + 1);
   clear area_labels area_locations map;              %%% [NB] hack. save memory.


   %%% STEP 8: Produce the marker image which will be used for the second
   %%% watershed.
   drawnow
   %%% The module has now produced a binary image of actual secondary
   %%% objects.  The gradient (Sobel) image was used for watershedding, which
   %%% produces very nice divisions between objects that are clumped, but it
   %%% is too stringent at the edges of objects that are isolated, and at the
   %%% edges of clumps of objects. Therefore, the stringently identified
   %%% secondary objects are used as markers for a second round of
   %%% watershedding, this time based on the original (intensity) image rather
   %%% than the gradient image.

   %%% Creates the structuring element that will be used for dilation.
   StructuringElement = strel('square',3);
   %%% Dilates the Primary Binary Image by one pixel (8 neighborhood).
   DilatedActualObjectsBinaryImage = imdilate(ActualObjectsBinaryImage, StructuringElement);
   %%% Subtracts the PrelimPrimaryBinaryImage from the DilatedPrimaryBinaryImage,
   %%% which leaves the PrimaryObjectOutlines.
   ActualObjectOutlines = DilatedActualObjectsBinaryImage - ActualObjectsBinaryImage;
   %%% [NB] hack. save memory.
   clear DilatedActualObjectsBinaryImage;
   %%% Produces the marker image which will be used for the watershed. The
   %%% foreground markers are taken from the ActualObjectsBinaryImage; the
   %%% background markers are taken from the same image as used in the first
   %%% round of watershedding: InvertedThresholdedOrigImage.
   BinaryMarkerImagePre2 = ActualObjectsBinaryImage | InvertedThresholdedOrigImage;
   %%% [NB] hack. save memory.
   clear InvertedThresholdedOrigImage ActualObjectsBinaryImage;
   %%% Overlays the ActualObjectOutlines to maintain distinctions between each
   %%% secondary object and the background.
   BinaryMarkerImage2 = BinaryMarkerImagePre2;
   %%% [NB] hack. save memory.
   clear BinaryMarkerImagePre2;

   BinaryMarkerImage2(ActualObjectOutlines == 1) = 0;

   %%% STEP 9: Perform the second watershed.
   %%% As described above, the second watershed is performed on the original
   %%% intensity image rather than on a gradient (Sobel) image.
   drawnow
   %%% Inverts the original image.
   InvertedOrigImage = imcomplement(CelltraceImage);
   %%% Overlays the foreground and background markers onto the
   %%% InvertedOrigImage, so there are black secondary object markers on top
   %%% of each dark secondary object, with black background.
   MarkedInvertedOrigImage = imimposemin(InvertedOrigImage, BinaryMarkerImage2);
   %%% [NB] hack. save memory.
   clear BinaryMarkerImage2 BinaryMarkerImage2;

   %%% Performs the watershed on the MarkedInvertedOrigImage.
   SecondWatershedPre = watershed(MarkedInvertedOrigImage);
   %%% [NB] hack.save memory
   clear MarkedInvertedOrigImage;
   %%% BUG WORKAROUND:
   %%% There is a bug in the watershed function of Matlab that often results in
   %%% the label matrix result having two objects labeled with the same label.
   %%% I am not sure whether it is a bug in how the watershed image is
   %%% produced (it seems so: the resulting objects often are nowhere near the
   %%% regional minima) or whether it is simply a problem in the final label
   %%% matrix calculation. Matlab has been informed of this issue and has
   %%% confirmed that it is a bug (February 2004). I think that it is a
   %%% reasonable fix to convert the result of the watershed to binary and
   %%% remake the label matrix so that each label is used only once. In later
   %%% steps, inappropriate regions are weeded out anyway.

   %%% [NB, WATERSHED BUG IN VERSION 2011A (Windows only) OR HIGHER HAS BEEN FIXED. SO CHECK VERSION FIRST]
   if verLessThan('matlab', '7.12.0') && ispc()
       SecondWatershedPre2 = im2bw(SecondWatershedPre,.5);
       SecondWatershed = bwlabel(SecondWatershedPre2);
       %%% [NB] hack.save memory
       clear SecondWatershedPre2;
   else
       %%% [BS, QUICK AND DIRTY HACK FROM PEKLMANS]
       SecondWatershed = double(SecondWatershedPre);
       %%% END OF BS-HACK BUGFIX FOR VERSION 2011 AND LATER?
   end
   %%% [NB] hack.save memory
   clear SecondWatershedPre;
   drawnow

   %%% STEP 10: As in step 7, remove objects that are actually background
   %%% objects.  See step 7 for description. This time, the edited primary object image is
   %%% used rather than the preliminary one, so that objects whose nuclei are
   %%% on the edge of the image and who are larger or smaller than the
   %%% specified size are discarded.

   %%% Finds the locations and labels for different regions.
   area_locations2 = find(SecondWatershed);
   area_labels2 = SecondWatershed(area_locations2);
   %%% Creates a sparse matrix with column as label and row as location,
   %%% with the value of the center at (I,J) if location I has label J.
   %%% Taking the maximum of this matrix gives the largest valued center
   %%% overlapping a particular label.  Tacking on a zero and pushing
   %%% labels through the resulting map removes any background regions.
   map2 = [0 full(max(sparse(area_locations2, area_labels2, EditedPrimaryBinaryImage(area_locations2))))];
   FinalBinaryImagePre = map2(SecondWatershed + 1);
   %%% [NB] hack. save memory
   clear SecondWatershed area_labels2 map2;

   %%% Fills holes in the FinalBinaryPre image.
   FinalBinaryImage = imfill(FinalBinaryImagePre, 'holes');
   %%% [NB] hack. save memory
   clear FinalBinaryImagePre;
   %%% Converts the image to label matrix format. Even if the above step
   %%% is excluded (filling holes), it is still necessary to do this in order
   %%% to "compact" the label matrix: this way, each number corresponds to an
   %%% object, with no numbers skipped.
   ActualObjectsLabelMatrixImage3 = bwlabel(FinalBinaryImage);
   %%% [NB] hack. save memory
   clear FinalBinaryImage;
   %%% The final objects are relabeled so that their numbers
   %%% correspond to the numbers used for nuclei.
   %%% For each object, one label and one label location is acquired and
   %%% stored.
   [LabelsUsed,LabelLocations] = unique(NucleiImage);
   %%% The +1 increment accounts for the fact that there are zeros in the
   %%% image, while the LabelsUsed starts at 1.
   LabelsUsed(ActualObjectsLabelMatrixImage3(LabelLocations(2:end))+1) = NucleiImage(LabelLocations(2:end));
   FinalLabelMatrixImagePre = LabelsUsed(ActualObjectsLabelMatrixImage3+1);
   %%% [NB] hack. save memory
   clear FinalBinaryImage LabelsUsed LabelLocations;
   %%% The following is a workaround for what seems to be a bug in the
   %%% watershed function: very very rarely two nuclei end up sharing one
   %%% "cell" object, so that one of the nuclei ends up without a
   %%% corresponding cell.  I am trying to determine why this happens exactly.
   %%% When the cell is measured, the area (and other
   %%% measurements) are recorded as [], which causes problems when dependent
   %%% measurements (e.g. perimeter/area) are attempted.  It results in divide
   %%% by zero errors and the mean area = NaN and so on.  So, the Primary
   %%% label matrix image (where it is nonzero) is written onto the Final cell
   %%% label matrix image pre so that every primary object has at least some
   %%% pixels of secondary object.
   FinalLabelMatrixImage = FinalLabelMatrixImagePre;
   %%% [NB] hack. save memory
   clear FinalLabelMatrixImagePre;
   FinalLabelMatrixImage(NucleiImage ~= 0) = NucleiImage(NucleiImage ~= 0);

   %[TS] insert to allow easy collecition of segmentations at all
   %different thresholds
   if max(FinalLabelMatrixImage(:))<intmax('uint16')
       cellFinalLabelMatrixImage{k} = uint16(FinalLabelMatrixImage); % if used for cells, few objects, reduce memory load
   else
       cellFinalLabelMatrixImage{k} = FinalLabelMatrixImage;
   end

   clear FinalLabelMatrixImage; % memory==low

end
%%%% [TS] %%%%%%%%%%%%%%%%%%%%%%%%%%%%% End of iteration %%%%%%%%%%%

clear AbsSobeledImage;
clear PrelimPrimaryBinaryImage;



%%%% [TS] %%%%%%%%%% ABSOLUTE SEGEMENTATION  Start  %%%%%%%%%%%

% this code combines knowledge of about the segementation at individual
% thresholds to one common segmentation, which will be superior and
% combines the advantage of high threshold (less/no false allocation to
% wrong cell) with the advantage of low thresholds (inclusion of cell
% boundaries)


% A) Reverse projection
FinalLabelMatrixImage  = zeros(size(cellFinalLabelMatrixImage{1}),'double');
for k=numThresholdsToTest:-1:1
   f = cellFinalLabelMatrixImage{k} ~=0;
   FinalLabelMatrixImage(f) = cellFinalLabelMatrixImage{k}(f);
end

% make a second loop, which creates second best object ID
% FinalLabelMatrixImageSurrogate  = zeros(size(FinalLabelMatrixImage),'double');
% if numThresholdsToTest > 1
%     for k=numThresholdsToTest:-1:1
%         f = cellFinalLabelMatrixImage{k} ~=0 && cellFinalLabelMatrixImage{k} ~= FinalLabelMatrixImage;
%         FinalLabelMatrixImageSurrogate(f) = cellFinalLabelMatrixImage{k}(f);
%     end
% end


% B) Make sure objects are separted

% Dilate segmentation by one pixel and reassign IDs. This is necessary
% because edge detection is done in next step to create 0 intensity pixels
% between IDa-IDb. However, without dilation to background, background-IDa
% boundaries would become extended in next step

% use code from spot qualtiy control showSpotsInControl.m
DistanceToDilate = 1;
%%% Creates the structuring element using the user-specified size.
StructuringElementMini = strel('disk', DistanceToDilate);
%%% Dilates the preliminary label matrix image (edited for small only).
DilatedPrelimSecObjectLabelMatrixImageMini = imdilate(FinalLabelMatrixImage, StructuringElementMini);
%%% Converts to binary.
DilatedPrelimSecObjectBinaryImageMini = im2bw(DilatedPrelimSecObjectLabelMatrixImageMini,.5);
%%% Computes nearest neighbor image of nuclei centers so that the dividing
%%% line between secondary objects is halfway between them rather than
%%% favoring the primary object with the greater label number.
[~, Labels] = bwdist(full(FinalLabelMatrixImage>0)); % We want to ignore MLint error checking for this line.
%%% Remaps labels in Labels to labels in FinalLabelMatrixImage.
if max(Labels(:)) == 0,
   Labels = ones(size(Labels));
end
ExpandedRelabeledDilatedPrelimSecObjectImageMini = FinalLabelMatrixImage(Labels);
RelabeledDilatedPrelimSecObjectImageMini = zeros(size(ExpandedRelabeledDilatedPrelimSecObjectImageMini));
RelabeledDilatedPrelimSecObjectImageMini(DilatedPrelimSecObjectBinaryImageMini) = ExpandedRelabeledDilatedPrelimSecObjectImageMini(DilatedPrelimSecObjectBinaryImageMini);
% Stop using code from showSpotsInControl.m
clear ExpandedRelabeledDilatedPrelimSecObjectImageMini;
% Create Boundaries

I1 = imfilter(RelabeledDilatedPrelimSecObjectImageMini, filter1); % [TS] reuse sobel filters from above
I2 = imfilter(RelabeledDilatedPrelimSecObjectImageMini, filter2);
AbsSobeledImage = abs(I1) + abs(I2);
clear I1; clear I2;                  %%% [NB] hack. save memory
edgeImage = AbsSobeledImage>0;    % detect edges
FinalLabelMatrixImage = RelabeledDilatedPrelimSecObjectImageMini .* ~edgeImage;   % set edges in Labelmatrix to zero
clear Labels; clear ExpandedRelabeledDilatedPrelimSecObjectImageMini;
clear edgeImage;

if max(FinalLabelMatrixImage(:)) ~= 0       % check if an object is present Empty Image Handling

   % C) Remove regions no longer connected to the primary object
   % Take code from Neighbour module
   distanceToObjectMax = 3;
   loadedImage = FinalLabelMatrixImage;
   props = regionprops(loadedImage,'BoundingBox');
   BoxPerObj = cat(1,props.BoundingBox);

   N = floor(BoxPerObj(:,2)-distanceToObjectMax-1);                    f = N < 1;                      N(f) = 1;
   S = ceil(BoxPerObj(:,2)+BoxPerObj(:,4)+distanceToObjectMax+1);      f = S > size(loadedImage,1);    S(f) = size(loadedImage,1);
   W = floor(BoxPerObj(:,1)-distanceToObjectMax-1);                    f = W < 1;                      W(f) = 1;
   E = ceil(BoxPerObj(:,1)+BoxPerObj(:,3)+distanceToObjectMax+1);      f = E > size(loadedImage,2);    E(f) = size(loadedImage,2);

   % create empty output
   FinalLabelMatrixImage2  = zeros(size(FinalLabelMatrixImage));
   numObjects =size(BoxPerObj,1);
   if numObjects>=1  % if objects present
       patchForPrimaryObject = false(1,numObjects);
       for k=1: numObjects  % loop through individual objects to safe computation
           miniImage = FinalLabelMatrixImage(N(k):S(k),W(k):E(k));
           bwminiImage = miniImage>0;
           labelmini = bwlabel(bwminiImage);

           miniImageNuclei = NucleiImage(N(k):S(k),W(k):E(k));
           bwParentOfInterest = miniImageNuclei == k;

           % now find the most frequent value. note that preobject will not be
           % completely within child at border of image

           NewChildID = labelmini(bwParentOfInterest);

           if isequal(NewChildID,0) % [TS 150120: only compute if an object is found, see other comments marked by TS 150120 for explanation]
               patchForPrimaryObject(k) = true;
           else
               NewChildID = NewChildID(NewChildID>0);
               WithParentIX = mode(NewChildID); % [TS 150120: note that MODE gives different behavior on 0 input in new MATLAB versions]
               bwOutCellBody = labelmini == WithParentIX;

               % now map back the linear indices
               [r, c] = find(bwOutCellBody);

               % get indices for final image (note that mini image might have
               % permitted regions of other cells).
               r = r-1+N(k);
               c = c-1+W(k);
               w = sub2ind(size(FinalLabelMatrixImage2),r,c);

               % Update Working copy of Final Segmentation image based on linear indices.
               FinalLabelMatrixImage2(w) = k;
           end
       end

   end
   % Now mimik standard outupt of calculations of standard module
   FinalLabelMatrixImage = FinalLabelMatrixImage2;


end

% duplicate penultimate row and column. Thus pixels at border will carry
% an object ID (and are detected by iBrain function to discard border cells);
FinalLabelMatrixImage(:,1)= FinalLabelMatrixImage(:,2);
FinalLabelMatrixImage(:,end)= FinalLabelMatrixImage(:,(end-1));
FinalLabelMatrixImage(1,:)= FinalLabelMatrixImage(2,:);
FinalLabelMatrixImage(end,:)= FinalLabelMatrixImage((end-1),:);


% [TS 150120: ensure that every primary object has a secondary object:
% in case that no secondary object could be found (which is related to
% CP's behavior of using rim of primary object as seed), use the primary
% segmentation of the missing objects as the secondary object]
% Note: this fix is after extending the pixels at the border since
% sometimes small 1 -pixel objects, which are lost, are sitting at the
% border of an image (and thus would be overwritten)

if any(patchForPrimaryObject)
   % [TS]: note the conservative behavior to track individual missing
   % objects; this is intended for backward compatibility, while a simple
   % query for missing IDs would be faster, it would be more general and
   % thus potentially conflict with the segementation results of prior
   % pipelines (in other regions than the objects lost by prior / default
   % behavior of segmentation modules)
   IDsOfObjectsToPatch = find(patchForPrimaryObject);
   needsToIncludePrimary = ismember(NucleiImage,IDsOfObjectsToPatch);
   FinalLabelMatrixImage(needsToIncludePrimary) = NucleiImage(needsToIncludePrimary);
end

%%%% [TS] %%%%%%%%%% ABSOLUTE SEGEMENTATION  End  %%%%%%%%%%%

if ~isfield(handles.Measurements,SecondaryObjectName)
   handles.Measurements.(SecondaryObjectName) = {};
end

if ~isfield(handles.Measurements,PrimaryObjectName)
   handles.Measurements.(PrimaryObjectName) = {};
end

handles = CPrelateobjects(handles,SecondaryObjectName,PrimaryObjectName,FinalLabelMatrixImage,NucleiImage,ModuleName);
%%% [NB] hack. save memory
clear NucleiImage;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% SAVE DATA TO HANDLES STRUCTURE %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
drawnow

%%% Saves the final, segmented label matrix image of secondary objects to
%%% the handles structure so it can be used by subsequent modules.
fieldname = ['Segmented',SecondaryObjectName];
handles.Pipeline.(fieldname) = FinalLabelMatrixImage;

%[TS removed propagation]

%%% Saves the ObjectCount, i.e. the number of segmented objects.
if ~isfield(handles.Measurements.Image,'ObjectCountFeatures')
   handles.Measurements.Image.ObjectCountFeatures = {};
   handles.Measurements.Image.ObjectCount = {};
end
column = find(~cellfun('isempty',strfind(handles.Measurements.Image.ObjectCountFeatures,SecondaryObjectName)));
if isempty(column)
   handles.Measurements.Image.ObjectCountFeatures(end+1) = {SecondaryObjectName};
   column = length(handles.Measurements.Image.ObjectCountFeatures);
end
handles.Measurements.Image.ObjectCount{handles.Current.SetBeingAnalyzed}(1,column) = max(FinalLabelMatrixImage(:));

%%% Saves the location of each segmented object
handles.Measurements.(SecondaryObjectName).LocationFeatures = {'CenterX','CenterY'};
tmp = regionprops(FinalLabelMatrixImage,'Centroid');
%%% [NB] hack. save memory.
Centroid = cat(1,tmp.Centroid);
if isempty(Centroid)
   Centroid = [0 0];   % follow CP's convention to save 0s if no object
end
handles.Measurements.(SecondaryObjectName).Location(handles.Current.SetBeingAnalyzed) = {Centroid};

% [TS] note that the following CP code would require additional
% calculations, which as default were always done and also used for
% visualization. If it should be included again, the code either has to be
% arranged back or , better, a check included, whether the outline should
% be saved
% %%% Saves images to the handles structure so they can be saved to the hard
% %%% drive, if the user requested.
% try
%     if ~strcmpi(SaveOutlines,'Do not save')
%         handles.Pipeline.(SaveOutlines) = LogicalOutlines;
%     end
% catch dummyError %[TS] bugfix for error message
%     error(['The object outlines were not calculated by the ', ModuleName, ' module, so these images were not saved to the handles structure. The Save Images module will therefore not function on these images. This is just for your information - image processing is still in progress, but the Save Images module will fail if you attempted to save these images.'])
% end


%%%%%%%%%%%%%%%%%%%%%%%
%%% DISPLAY RESULTS %%%
%%%%%%%%%%%%%%%%%%%%%%%
drawnow

ThisModuleFigureNumber = handles.Current.(['FigureNumberForModule',CurrentModule]);
if any(findobj == ThisModuleFigureNumber)

   %%%% [TS] %%%%%%%%%%%%%%%%%%%%%%%%%%%%% Code for visualization %%%%%%%%%%%
   %%%%%%% Rearranged: Inculde visualization into a conditional statement starting
   %%%%%%% only on local machine, but not CPCluster


   %%% Calculates the ColoredLabelMatrixImage for displaying in the figure
   %%% window in subplot(2,2,2).
   ColoredLabelMatrixImage = CPlabel2rgb(handles,FinalLabelMatrixImage);
   %%% Calculates OutlinesOnOrigImage for displaying in the figure
   %%% window in subplot(2,2,3).
   %%% Note: these outlines are not perfectly accurate; for some reason it
   %%% produces more objects than in the original image.  But it is OK for
   %%% display purposes.
   %%% Maximum filters the image with a 3x3 neighborhood.
   MaxFilteredImage = ordfilt2(FinalLabelMatrixImage,9,ones(3,3),'symmetric');
   %%% Determines the outlines.
   IntensityOutlines = FinalLabelMatrixImage - MaxFilteredImage;
   %%% [NB] hack.s ave memory.
   clear MaxFilteredImage;
   %%% Converts to logical.
   warning off MATLAB:conversionToLogical
   LogicalOutlines = logical(IntensityOutlines);
   %%% [NB] hack.s ave memory.
   clear IntensityOutlines;
   warning on MATLAB:conversionToLogical

   % [TS140327 Start]: The following passage had a difference code in
   % \ethz_share2_matlab\CellProfiler\Modules\IdentifySecondaryIterative.m
   % and the version of the main SVN repository


   % Determines the grayscale intensity to use for the cell outlines.
   %[NB-HACK] so that images are not so dim!!!!
   ObjectOutlinesOnOrigImage = CelltraceImage;
ObjectOutlinesOnOrigImage=ObjectOutlinesOnOrigImage-quantile(CelltraceImage(:), 0.025);
   ObjectOutlinesOnOrigImage(ObjectOutlinesOnOrigImage<0)=0;
ObjectOutlinesOnOrigImage(ObjectOutlinesOnOrigImage>quantile(ObjectOutlinesOnOrigImage(:), 0.95))=quantile(ObjectOutlinesOnOrigImage(:), 0.95);
   LineIntensity = quantile(ObjectOutlinesOnOrigImage(:), 0.99);

   %%% Overlays the outlines on the original image.
   %ObjectOutlinesOnOrigImage = CelltraceImage;

   % [TS140327 End]



   ObjectOutlinesOnOrigImage(LogicalOutlines) = LineIntensity;
   %%% Calculates BothOutlinesOnOrigImage for displaying in the figure
   %%% window in subplot(2,2,4).
   %%% Creates the structuring element that will be used for dilation.
   StructuringElement = strel('square',3);
   %%% Dilates the Primary Binary Image by one pixel (8 neighborhood).
   DilatedPrimaryBinaryImage = imdilate(EditedPrimaryBinaryImage, StructuringElement);
   %%% Subtracts the PrelimPrimaryBinaryImage from the DilatedPrimaryBinaryImage,
   %%% which leaves the PrimaryObjectOutlines.
   PrimaryObjectOutlines = DilatedPrimaryBinaryImage - EditedPrimaryBinaryImage;
   %%% [NB] hack. save memory.
   clear DilatedPrimaryBinaryImage EditedPrimaryBinaryImage;
   BothOutlinesOnOrigImage = ObjectOutlinesOnOrigImage;
   BothOutlinesOnOrigImage(PrimaryObjectOutlines == 1) = LineIntensity;
   %%% [NB] hack. save memory.
   clear PrimaryObjectOutlines LineIntensity;

   %%%%%%%%%%%%%%%%%%%%%%%% END OF INITIATION OF VISUALIZATION
   %%%%%%%%%%%%%%%%%%%%%%%% (rearrangement)


   %%% Activates the appropriate figure window.
   CPfigure(handles,'Image',ThisModuleFigureNumber);
   if handles.Current.SetBeingAnalyzed == handles.Current.StartingImageSet
       CPresizefigure(CelltraceImage,'TwoByTwo',ThisModuleFigureNumber);
   end
   ObjectCoverage = 100*sum(sum(FinalLabelMatrixImage > 0))/numel(FinalLabelMatrixImage);

   %[TS] display range of thresholds. Which is useful if limits for treshold
   %should be used
   % uicontrol(ThisModuleFigureNumber,'Style','Text','Units','Normalized','Position',[0.25 0.01 .6 0.04],...
   %         'BackgroundColor',[.7 .7 .9],'HorizontalAlignment','Left','String',sprintf('Threshold: %0.3f               %0.1f%% of image consists of objects',Threshold,ObjectCoverage),'FontSize',handles.Preferences.FontSize);


   ThresholdFirst  = ThresholdArray{1};
   ThresholdLast = ThresholdArray{numThresholdsToTest};
uicontrol(ThisModuleFigureNumber,'Style','Text','Units','Normalized','Position',[0.25 0.01 .6 0.04],...
       'BackgroundColor',[.7 .7 .9],'HorizontalAlignment','Left','String',sprintf('Threshold: Start %0.5f End %0.5f                %0.1f%% of image consists of objects',ThresholdFirst,ThresholdLast,ObjectCoverage),'FontSize',handles.Preferences.FontSize);

   %%% A subplot of the figure window is set to display the original image.
   subplot(2,2,1);
   CPimagesc(CelltraceImage,handles);
   title(['Input Image, cycle # ',num2str(handles.Current.SetBeingAnalyzed)]);
   %%% A subplot of the figure window is set to display the colored label
   %%% matrix image.
   subplot(2,2,2);
   CPimagesc(ColoredLabelMatrixImage,handles);
   clear ColoredLabelMatrixImage
   title(['Outlined ',SecondaryObjectName]);
   %%% A subplot of the figure window is set to display the original image
   %%% with secondary object outlines drawn on top.
   subplot(2,2,3);
   CPimagesc(ObjectOutlinesOnOrigImage,handles);
   clear ObjectOutlinesOnOrigImage
   title([SecondaryObjectName, ' Outlines on Input Image']);
   %%% A subplot of the figure window is set to display the original
   %%% image with outlines drawn for both the primary and secondary
   %%% objects.
   subplot(2,2,4);
   CPimagesc(BothOutlinesOnOrigImage,handles);
   clear BothOutlinesOnOrigImage;
   title(['Outlines of ', PrimaryObjectName, ' and ', SecondaryObjectName, ' on Input Image']);
end






%%%%%%%%%%%%%%%%%%%%%
%% display results %%
%%%%%%%%%%%%%%%%%%%%%

        


%%%%%%%%%%%%%%%%%%%%
%% prepare output %%
%%%%%%%%%%%%%%%%%%%%

%%% Structure output arguments for later storage in the .HDF5 file
data = struct();

output_args = struct();
output_args.Cells = IdentifiedCells;

%% ---------------------------- module specific ---------------------------
%% ------------------------------------------------------------------------


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% jterator output

%%% write measurement data to HDF5
writedata(handles, data);

%%% write temporary pipeline data to HDF5
writeoutputargs(handles, output_args);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
