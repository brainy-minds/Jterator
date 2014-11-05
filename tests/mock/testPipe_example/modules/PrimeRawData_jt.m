function PrimeRawData_jt(handles_filename)

import jterator.api.io.*;


fprintf('jt - %s:\n', mfilename) 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% jterator input

%%% retrieve handles from .JSON files
handles = get_handles(handles_filename);

%%% retrieve initial values from handles
values = read_input_values(handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% ------------------------------------------------------------------------
% ---------------------------- module specific ----------------------------

%%%%%%%%%%%%%%%%%%%%
%% input handling %%
%%%%%%%%%%%%%%%%%%%%

ImagePath = values.ImageDirectory;
ImageFilename = values.ImageFilename;
StatsPath = values.StatsDirectory;
StatsFilename = values.StatsFilename;


%%%%%%%%%%%%%%%%
%% processing %%
%%%%%%%%%%%%%%%%

%%% load primary raw data from disk (in this test scenario this is an image)
% for original intensity images
OrigImage = double(imread(fullfile(ImagePath, ImageFilename)));
% for illumination correction statistics
structStats = load(fullfile(StatsPath, StatsFilename));
MeanImage = double(structStats.stat_values.mean);
StdImage = double(structStats.stat_values.std);


%%%%%%%%%%%%%%%%%%%%
%% prepare output %%
%%%%%%%%%%%%%%%%%%%%

%%% structure output arguments for later storage in the .HDF5 file
output_args = struct();
output_args.OrigImage = OrigImage;
output_args.StatsMeanImage = MeanImage;
output_args.StatsStdImage = StdImage;

% ---------------------------- module specific ----------------------------
%% ------------------------------------------------------------------------


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% jterator output

%%% create .HDF5 file
build_hdf5(handles);

%%% save loaded data in .HDF5 file
write_output_args(handles, output_args);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end
