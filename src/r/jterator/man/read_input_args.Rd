\name{read_input_args}
\alias{read_input_args}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Reading input data for jterator module from HDF5 file
}
\description{
The dataset locations in an HDF5 file are defined in the handles.
}
\usage{
read_input_args(handles)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{handles}{
list as provided by get_handles function
}
}
\details{
%%  ~~ If necessary, more details than the description above ~~
}
\value{
%%  ~Describe the value returned
%%  If it is a LIST, use
%%  \item{comp1 }{Description of 'comp1'}
%%  \item{comp2 }{Description of 'comp2'}
%% ...
}
\references{
%% ~put references to the literature/web site here ~
}
\author{
Markus Herrmann <markus.herrmann@imls.uzh.ch>
}
\note{
%%  ~~further notes~~
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
%% ~~objects to See Also as \code{\link{help}}, ~~~
}
\examples{
##---- Should be DIRECTLY executable !! ----
##-- ==>  Define data, use random,
##--	or do  help(data=index)  for the standard data sets.

## The function is currently defined as
function (handles) 
{
    mfilename <- "read_input_args"
    hdf5_filename <- handles$hdf5_filename
    input_args <- list()
    for (key in names(handles$input_keys)) {
        field <- handles$input_keys[[key]]
        input_args[[key]] <- list()
        if ("hdf5_location" \%in\% names(field)) {
            input_args[[key]]$variable <- h5read(hdf5_filename, 
                field$hdf5_location)
            cat(sprintf("jt -- \%s: loaded dataset '\%s' from HDF5 group: \"\%s\"\n", 
                mfilename, key, field$hdf5_location))
        }
        else if ("parameter" \%in\% names(field)) {
            input_args[[key]]$variable <- field$parameter
            cat(sprintf("jt -- \%s: parameter '\%s': \"\%s\"\n", 
                mfilename, key, paste(field$parameter, collapse = ",")))
        }
        else {
            stop("Possible variable keys are 'hdf5_location' or 'parameter'")
        }
        if ("class" \%in\% names(field)) {
            input_args[[key]]$class <- field$class
        }
        if ("attributes" \%in\% names(field)) {
            input_args[[key]]$attributes <- field$attributes
        }
    }
    return(input_args)
  }
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
