function function1(input_args)

% first input argutent is hdf5 filename
hdf5_filename = input_args{1};

% further input arguments are locations in hdf5 file
input_group = input_args{2};
input_data = h5varget(hdf5_filename, input_group);

%--------------------------------------------------------------------

% processing
output_data = input_data;

%--------------------------------------------------------------------

% last input arguement is location of output in hdf5 file 
h5datacreate(hdf5_filename, input_args{end}, 'type','double', 'size',size(output_data)); % type, size
h5write(hdf5_filename, input_args{end}, output_data);

end