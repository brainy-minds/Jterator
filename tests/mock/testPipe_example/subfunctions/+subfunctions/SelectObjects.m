function [SelectedObjects, Objects2Cut, ObjectsNot2Cut] = SelectObjects(Objects, thresholds)

% Measure basic area/shape features
props = regionprops(logical(Objects,'Area','Solidity','Perimeter');

% Features used for object selection
objSolidity{i} = cat(1,props.Solidity);
objArea{i} = cat(1,props.Area);
tmp = log((4*pi*cat(1,props.Area)) ./ ((cat(1,props.Perimeter)+1).^2))*(-1);
tmp(tmp<0) = 0;
objFormFactor{i} = tmp;

% Select objects based on these features (user defined thresholds)
obj2cut = objSolidity{i} < thresholds.Solidity & objFormFactor{i} > thresholds.FormFactor ...
    & objArea{i} > thresholds.LowerSize & objArea{i} < thresholds.UpperSize;
objNot2cut = ~obj2cut;
            
objSelected = zeros(size(obj2cut));
objSelected(obj2cut) = 1;
objSelected(objNot2cut) = 2;
imSelected(:,:,i) = rplabel(logical(Objects,[],objSelected);

% Create mask image with objects selected for cutting
Objects2Cut = zeros(size(Objects));
Objects2Cut(imSelected(:,:,i)==1) = 1;

% Store remaining objects that are omitted from cutting
tmp = zeros(size(Objects));
tmp(imSelected(:,:,i)==2) = 1;
ObjectsNot2Cut(:,:,i) = logical(tmp);

end