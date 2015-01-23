importall jterator
using MAT

mfilename = match(r"([^/]+)\.jl$", @__FILE__()).captures[1]

###############################################################################
## jterator input

@printf("jt - %s:\n", mfilename)

### read YAML from standard input
handles_stream = readall(STDIN)

### retrieve handles from .YAML files
handles = gethandles(handles_stream)

### read input arguments from .HDF5 files
input_args = readinputargs(handles)

### check whether input arguments are valid
input_args = checkinputargs(input_args)

###############################################################################


####################
## input handling ##
####################

orig_image_dapi = input_args["DapiImage"]
orig_image_celltrace = input_args["CelltraceImage"]
stats_directory = input_args["StatsDirectory"]
stats_filename_dapi = input_args["StatsFilenameDapi"]
stats_filename_celltrace = input_args["StatsFilenameCelltrace"]


################
## processing ##
################

### helper function for the actual illumination correction step
function correct(orig_image, mean_image, std_image)
    orig_image[orig_image .== 0] = 1 
    corr_image = (log10(orig_image) - mean_image) ./ std_image
    corr_image = (corr_image .* mean(std_image)) + mean(mean_image)
    corr_image = 10 .^ corr_image
end

### build absolute path to illumination correction file
stats_path = joinpath(stats_directory, stats_filename_dapi)
if ~isabspath(stats_path)
    stats_path = joinpath(pwd(), stats_path)
end

### load illumination correction file
stats = matread(stats_path)

### extract pre-calculated statistics
mean_image = float64(stats["stat_values"]["mean"])
std_image = float64(stats["stat_values"]["std"])

### correct intensity image for illumination artefact
corr_image_dapi = correct(orig_image_dapi, mean_image, std_image)

### build absolute path to illumination correction file
stats_path = joinpath(stats_directory, stats_filename_celltrace)
if ~isabspath(stats_path)
    stats_path = joinpath(pwd(), stats_path)
end

### load illumination correction file
stats = matread(stats_path)

### extract pre-calculated statistics
mean_image = float64(stats["stat_values"]["mean"])
std_image = float64(stats["stat_values"]["std"])

### correct intensity image for illumination artefact
corr_image_celltrace = correct(orig_image_celltrace, mean_image, std_image)


#####################
## display results ##
#####################


####################
## prepare output ##
####################

output_args = Dict()
output_args["CorrImageDapi"] = corr_image_dapi
output_args["CorrImageCelltrace"] = corr_image_celltrace

data = Dict()


###############################################################################
## jterator output

### write measurement data to HDF5
writedata(handles, data)

### write temporary pipeline data to HDF5
writeoutputargs(handles, output_args)

###############################################################################
