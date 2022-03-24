import pandas as pd
import matplotlib.pyplot as plt
import matplotlib as mpl
import seaborn as sns
import os
from mpl_toolkits.mplot3d import Axes3D
from PIL import Image
import os
import matplotlib as mpl
if os.environ.get('DISPLAY', '') == '':
    print('no display found. Using non-interactive Agg backend')
#     mpl.use('Agg')
import future.utils
mpl.rcParams["text.usetex"] = False
sns.set_style("whitegrid")
sns.axes_style("whitegrid")
sns.set_theme(style="white", rc={"axes.facecolor": (0, 0, 0, 0)})
import json
import numpy as np

def heatmapsplot(results, measure, model, x='pr', y='gam', grouping="eps", filename = "new"):
    
    params = ['graph','nruns','n', 'k','gam','eps', 'pr']
    paramsnames = ['graph', 'nruns', 'n', 'k', '$\gamma$', '$\epsilon$', '$p_r$']
    parmapping = dict(zip(params, paramsnames))

    sns.set_style("whitegrid")
    sns.set(font_scale=0.8)

    values_to_plot = sorted(list(results[grouping].unique()))

    with sns.axes_style("whitegrid"):

        fig, axes = plt.subplots(nrows=2, ncols=3, figsize=(15, 6.3), dpi=600)
        fmt = ".2f"
        annot = True
        if measure=='avg_niter':
            fmt = ".0f"

        list_of_labels = ["a", "b", "c", "d", "e", "f", "g", "h", "i"]
        lab = 0
        i = 0
        for val in values_to_plot:
            data = results[results["graph"]=="er"]
            data = data[data[grouping] == val]
            df = data.pivot(x, y, measure)
            a=sns.heatmap(df, vmin=min(results[measure]), vmax=max(results[measure]), cmap='RdBu_r', cbar=False, fmt=fmt, annot=annot, ax= axes[0, i])
            axes[0, i].set_ylabel(r'{}'.format(parmapping[x]), fontsize=10)
            axes[0, i].set_xlabel(r'{}'.format(parmapping[y]), fontsize=10)
            axes[0, i].set_title(r'({}) ER $\epsilon$ = {}'.format(list_of_labels[lab], val))
            lab +=1
            i+=1

        i = 0
        for val in values_to_plot:
            data = results[results["graph"]=="ba"]
            data = data[data[grouping] == val]
            df = data.pivot(x, y, measure)
            sns.heatmap(df, vmin=min(results[measure]), vmax=max(results[measure]), cmap='RdBu_r', cbar=False, fmt=fmt, annot=annot, ax= axes[1, i])
            axes[1, i].set_ylabel(r'{}'.format(parmapping[x]), fontsize=10)
            axes[1, i].set_xlabel(r'{}'.format(parmapping[y]), fontsize=10)
            axes[1, i].set_title(r'({}) BA $\epsilon$ = {}'.format(list_of_labels[lab], val))
            i+=1
            lab+=1
        for ax in axes.flat:
            ax.tick_params(axis='x', which='major', pad=-2)
            ax.tick_params(axis='y', which='major', pad=-2)
        cax = fig.add_axes([0.92, 0.22, 0.01, 0.6])
        cbar = fig.colorbar(ax.get_children()[0], cax=cax, orientation="vertical")
        for t in cbar.ax.get_yticklabels():
            t.set_fontsize(10)
        cbar.outline.set_visible(False)
        cbar.ax.tick_params()
        plt.subplots_adjust(left=0.05, hspace=0.3)
        # plt.tight_layout()
        plt.savefig("plots/aggregate/hm {} {}.png".format(model, measure))
        # plt.show()
        plt.close()

resultsrewiring = pd.read_csv("finals/aggregate rewiring.csv", index_col=[0])
resultstriangles = pd.read_csv("finals/aggregate triangles rewiring.csv", index_col=[0])
measures = ['avg_ncluster']
for measure in measures:
    heatmapsplot(resultsrewiring, measure, "rewiring")

for measure in measures:
    heatmapsplot(resultstriangles, measure, "triangles")