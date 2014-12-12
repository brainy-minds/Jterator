importall jterator
using MAT

mfilename = match(r"([^/]+)\.jl$", @__FILE__()).captures[1]

###############################################################################
## jterator input

@printf("jt - %s\n", mfilename)

### read YAML from standard input
handles_stream = readall(STDIN)

### retrieve handles from .YAML files
handles = gethandles(handles_stream)

### read input arguments from .HDF5 files
input_args = readinputargs(handles)

### check whether input arguments are valid
input_args = checkinputargs(input_args)

###############################################################################


## ----------------------------------------------------------------------------
## ------------------------------ module specific -----------------------------

####################
## input handling ##
####################

orig_image = input_args["DapiImage"];
stats_directory = input_args["StatsDirectory"];
stats_filename = input_args["StatsFilename"];


################
## processing ##
################

### load illumination correction files
stats_path = joinpath(stats_directory, stats_filename)
if ~isabspath(stats_path)
    stats_path = joinpath(pwd(), stats_path)
end
stats = matread(stats_path)

### extract stats images
mean_image = float64(stats["stat_values"]["mean"])
std_image = float64(stats["stat_values"]["std"])

### correct for illumination
orig_image = orig_image + 0.1; # prevent zeros
corr_image = (log10(orig_image) - mean_image) ./ std_image;
corr_image = (corr_image .* mean(std_image)) + mean(mean_image);
corr_image = 10 .^ corr_image;


#################
## make figure ##
#################


####################
## prepare output ##
####################

output_args = Dict()
output_args["CorrImage"] = corr_image
data = Dict()


## ------------------------------ module specific -----------------------------
## ----------------------------------------------------------------------------


###############################################################################
## jterator output

### write measurement data to HDF5
writedata(handles, data)

### write temporary pipeline data to HDF5
writeoutputargs(handles, output_args)

###############################################################################
