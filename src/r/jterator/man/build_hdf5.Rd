\name{build_hdf5}
\alias{build_hdf5}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Creating HDF5 file for jterator project
}
\description{
Create empty HDF5 file
}
\usage{
build_hdf5(handles)
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
    mfilename <- "build_hdf5"
    hdf5_filename <- handles$hdf5_filename
    file_created <- h5createFile(hdf5_filename)
    cat(sprintf("jt -- \%s: created HDF5 file: \"\%s\"\n", mfilename, 
        hdf5_filename))
  }
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
