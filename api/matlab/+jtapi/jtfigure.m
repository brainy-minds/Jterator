function figure_url = jtfigure(fig, filename, fig_format)
    if fig_format == 'pdf'
        set(fig, 'PaperPosition', [0 0 7 7], 'PaperSize', [7 7]);
        saveas(fig, sprintf('figures/%s', filename), 'pdf');
    elseif fig_format == 'plotly'
        figure_obj = fig2plotly(fig);    
        figure_url = figure_obj.url;
    end
end
