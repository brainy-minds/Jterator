import plotly.plotly as py
import matplotlib.pyplot as plt


def jtfigure(fig, filename, fig_format):
    if fig_format == 'pdf':
        plt.savefig('figures/%s.pdf' % filename, format='pdf')
        plt.close()
    elif fig_format == 'plotly':
        figure_url = py.plot_mpl(fig, filename=filename)
        return figure_url
