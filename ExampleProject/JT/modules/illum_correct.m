function illum_correct(handles_filename)

    % Define expected input and output arguments for module in JSON:
    %
    % $$$ input_args $$$
    %
    % "input_keys": {
    %   "OrigImage": {
    %       "hdf5_location": "/Input/illum_correct/OrigImage",
    %       "class": "double",
    %       "attributes": [ "nonempty", "size", [1,10] ]
    %   },
    %
    %   "Filename": {
    %       "hdf5_location": "/Input/illum_correct/Filename",
    %       "class": "char",
    %       "attributes": [ "nrows", 1 ]
    %   }
    % }
    %
    % $$$
    %
    %
    % $$$ output_args $$$
    %
    % "output_keys": {
    %    "CorrImage": {
    %        "hdf5_location": "/Output/read_filenames/SegmImage",
    %        "class": "double",
    %        "attributes": [ "positive" ]
    %    }
    % }
    %
    % $$$

    handles = module_m.get_handles(handles_filename);

    input_args = module_m.read_input_args(handles);
    input_args = module_m.check_input_args(input_args);

    output_args = illum_correct_run(input_args)

    module_m.write_output_args(handles, output_args)

end


function output_args = illum_correct_run(input_args)

    % -------------------------------------------------------------------------
    % here comes the actual processing


    % -------------------------------------------------------------------------

end
