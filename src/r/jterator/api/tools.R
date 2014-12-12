library(plotly)
library(ggplot)


jtfigure <- function(fig, filename, fig_format) {
    if (fig_format == 'pdf') {
        pdf(sprintf("figures/%s.pdf", filename))
        print(fig)
        dev.off()
    }
    else if (fig_format == 'plotly') {
        py <- plotly()
        figure_url <- py$ggplotly()
        return(figure_url)
    }
}
