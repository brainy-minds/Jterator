\name{get_handles}
\alias{get_handles}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Reading jterator handles file
}
\description{
Reads opened YAML file
}
\usage{
get_handles(handles_stream)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{handles_stream}{
FileObj instance
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
function (handles_stream) 
{
    mfilename <- "get_handles"
    handles <- yaml.load_file(handles_stream)
    cat(sprintf("jt -- \%s: loaded 'handles' from standard input\n", 
        mfilename))
    return(handles)
  }
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
