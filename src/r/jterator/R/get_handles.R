get_handles <-
function(handles_stream) {

    mfilename <- "get_handles"
    handles <- yaml.load_file(handles_stream)

    cat(sprintf("jt -- %s: loaded 'handles' from standard input\n", 
                mfilename))

    return(handles)
}
