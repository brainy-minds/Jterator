\name{check_input_args}
\alias{check_input_args}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Checking input arguments for jterator module
}
\description{
Checks input arguments for class and attributes (if provided in the handles)
}
\usage{
check_input_args(input_args)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{input_args}{
list of strings specifying groups in the HDF5 file
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
function (input_args) 
{
    mfilename <- "check_input_args"
    checked_input_args <- list()
    for (key in names(input_args)) {
        field <- input_args[[key]]
        if ("class" \%in\% names(field)) {
            expected_class <- input_args[[key]]$class
            loaded_class <- class(input_args[[key]]$variable)
            if (expected_class != loaded_class) {
                stop(sprintf("argument '\%s' is of \"class\" '\%s' instead of expected '\%s'", 
                  key, loaded_class, expected_class))
            }
            cat(sprintf("jt -- \%s: argument '\%s' passed check\n", 
                mfilename, key))
        }
        else {
            cat(sprintf("jt -- \%s: argument '\%s' not checked\n", 
                mfilename, key))
        }
        checked_input_args[[key]] <- input_args[[key]]$variable
    }
    return(checked_input_args)
  }
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
