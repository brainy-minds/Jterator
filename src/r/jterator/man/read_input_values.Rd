\name{read_input_values}
\alias{read_input_values}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Reading input data for jterator module from disk
}
\description{

}
\usage{
read_input_values(handles)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{handles}{
%%     ~~Describe \code{handles} here~~
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
    mfilename <- "read_input_values"
    values <- list()
    for (key in names(handles$input_keys)) {
        values[key] <- handles$input_keys[[key]]$value
        cat(sprintf("jt -- \%s: value '\%s': \"\%s\"\n", mfilename, 
            key, values[key]))
    }
    return(values)
  }
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
