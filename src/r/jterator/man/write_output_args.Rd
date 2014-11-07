\name{write_output_args}
\alias{write_output_args}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Writing output data of jterator module to HDF5 file
}
\description{
The dataset locations in an HDF5 file are defined in the handles.
}
\usage{
write_output_args(handles, output_args)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{handles}{
list as provided by get_handles function
}
  \item{output_args}{
list of output arguments
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
function (handles, output_args) 
{
    mfilename <- "write_output_args"
    hdf5_filename <- handles$hdf5_filename
    for (key in names(output_args)) {
        hdf5_location <- handles$output_keys[[key]]$hdf5_location
        h5createDataset(hdf5_filename, hdf5_location, dims = dim(output_args[[key]]), 
            storage.mode = storage.mode(output_args[[key]]))
        h5write(output_args[[key]], hdf5_filename, hdf5_location)
        cat(sprintf("jt -- \%s: wrote dataset '\%s' to HDF5 group: \"\%s\"\n", 
            mfilename, key, field$hdf5_location))
    }
  }
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
