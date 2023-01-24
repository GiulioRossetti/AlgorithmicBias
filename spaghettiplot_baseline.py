import matplotlib.pyplot as plt
import matplotlib as mpl
import seaborn as sns
import os
from matplotlib.colors import LinearSegmentedColormap
import future.utils
import numpy as np
import tqdm
plt.rcParams['axes.facecolor']='white'
plt.rcParams['savefig.facecolor']='white'
sns.set_style("whitegrid")

print('matplotlib: {}'. format(mpl.__version__))

def hex_to_rgb(value):
    '''
    Converts hex to rgb colours
    value: string of 6 characters representing a hex colour.
    Returns: list length 3 of RGB values'''
    value = value.strip("#") # removes hash symbol if present
    lv = len(value)
    return tuple(int(value[i:i + lv // 3], 16) for i in range(0, lv, lv // 3))


def rgb_to_dec(value):
    '''
    Converts rgb to decimal colours (i.e. divides each value by 256)
    value: list (length 3) of RGB values
    Returns: list (length 3) of decimal values'''
    return [v/256 for v in value]

def get_continuous_cmap(hex_list, float_list=None):
    ''' creates and returns a color map that can be used in heat map figures.
        If float_list is not provided, colour map graduates linearly between each color in hex_list.
        If float_list is provided, each color in hex_list is mapped to the respective location in float_list. 
        
        Parameters
        ----------
        hex_list: list of hex code strings
        float_list: list of floats between 0 and 1, same length as hex_list. Must start with 0 and end with 1.
        
        Returns
        ----------
        colour map'''
    rgb_list = [rgb_to_dec(hex_to_rgb(i)) for i in hex_list]
    if float_list:
        pass
    else:
        float_list = list(np.linspace(0,1,len(rgb_list)))
    cdict = dict()
    for num, col in enumerate(['red', 'green', 'blue']):
        col_list = [[float_list[i], rgb_list[i][num], rgb_list[i][num]] for i in range(len(float_list))]
        cdict[col] = col_list
    cmp = LinearSegmentedColormap('my_cmp', segmentdata=cdict, N=256)
    return cmp

heatmap_hex_list = ['#357db0', '#ce2626']
heatmap_cmap=get_continuous_cmap(heatmap_hex_list)

spaghetti_hex_list = ['#357db0', '#18A558', '#ce2626']
spaghetti_cmap=get_continuous_cmap(spaghetti_hex_list)


def from_res_to_iterations(name, nr):
    res = open("{}.csv".format(name))
    iterations = []
    it = 0
    for line in res.readlines():
        iterations.append(dict())
        iterations[it]['iteration'] = it
        iterations[it]['status'] = dict()

        opinions = line.strip().split(',')

        for i in range(len(opinions)):
            iterations[it]['status'][i] = float(opinions[i])
            iterations[it]['node_count'] = {0: 0},
            iterations[it]['status_delta'] = {0: 0}

        it += 1
        
    return iterations

def evolution(iterations, hex_list, fig, ax):

    spaghetti_hex_list = ['#357db0', '#18A558', '#ce2626']


    """
    Generates the plot

    :param filename: Output filename
    :param percentile: The percentile for the trend variance area
    """

    nodes2opinions = {}
    node2col = {}

    last_it = iterations[-1]['iteration'] + 1
    last_seen = {}

    for it in iterations:
        sts = it['status']
        its = it['iteration']
        for n, v in sts.items():
            if n in nodes2opinions:
                last_id = last_seen[n]
                last_value = nodes2opinions[n][last_id]

                for i in range(last_id, its):
                    nodes2opinions[n][i] = last_value

                nodes2opinions[n][its] = v
                last_seen[n] = its
            else:
                nodes2opinions[n] = [0]*last_it
                nodes2opinions[n][its] = v
                last_seen[n] = 0
                if v < 0.33:
                    node2col[n] = spaghetti_hex_list[0]
                elif 0.33 <= v <= 0.66:
                    node2col[n] = spaghetti_hex_list[1]
                else:
                    node2col[n] = spaghetti_hex_list[2]

    mx = 0
    for k, l in future.utils.iteritems(nodes2opinions):
        if mx < last_seen[k]:
            mx = last_seen[k]
        x = list(range(0, last_seen[k]))
        y = l[0:last_seen[k]]
        ax.plot(x, y, lw=1.5, alpha=0.5, color=node2col[k])
    
    # ax.set_ylim(-0.1, 1.1)
    # ax.set_xlim(0, 1000)
    # ax.tick_params(axis='both', which='major', labelsize=4, pad=0) 
    # ax.set_xlabel("o", fontsize=5)
    # ax.set_ylabel("t", fontsize=5)               
    # plt.grid(axis = 'both', which='both')
    plt.tight_layout()

    
from tqdm import tqdm

def spaghettigridbye(results, imgfolder):
    mops = list(results.media_op.unique())
    pmlist = sorted(list(results.p_media.unique()))
    elist = sorted(list(results.eps.unique()))
    glist=sorted(list(results.gam.unique()))
    sns.set_style("whitegrid")
    i=0
    if imgfolder == "moderate":
        mo = '0.5'
    for e in elist:
        fig, axes = plt.subplots(ncols=len(glist), nrows=len(pmlist), figsize=(6, 6), dpi=600, sharey=True)
        row=0
        for pm in pmlist:
            with tqdm(total=len(pmlist)*len(glist)) as pbar:
                col=0
                for g in glist:
                    name = f'for_spaghetti media mo[{mo}] p{pm} e{e} g{g} gm{g} mi1000000'
                    results = results[results['media_op']==mo]
                    results = results[results['eps']==e]
                    results = results[results['p_media']==pm]
                    results = results[results['gam']==g]
                    iterations = from_res_to_iterations(name, 1)
                    evolution(iterations, spaghetti_hex_list, fig=fig, ax=axes[row,col])
                    axes[row,col].set_title(r"$p_m$={}, $\epsilon$={}, $\gamma={}$".format(pm, e, g), fontsize=5)
                    col+=1    
            row+=1
            pbar.update(1)
        name = f'spaghetti media {imgfolder} e{e}'
        i+=1
        plt.savefig(f"plots/{imgfolder}/{name}.png")
        plt.close()

import os
import networkx as nx
import ndlib.models.ModelConfig as mc
import ndlib.models.opinions as op
import warnings
warnings.filterwarnings("ignore")

n = 100
graph = nx.complete_graph(n)
max_it = 1000000

pm=0.0
t = 'baseline'
for e in [0.2, 0.3, 0.4, 0.5]:
    for g in [0.0, 0.5, 1.0, 1.5]:
        model = op.AlgorithmicBiasMediaModel(graph)
        config = mc.Configuration()
        config.add_model_parameter("epsilon", e)
        config.add_model_parameter("gamma", g)
        config.add_model_parameter("gamma_media", g)
        config.add_model_parameter("k", 1)
        config.add_model_parameter("p", pm)
        model.set_initial_status(config)
        model.set_media_opinions([0.5])
        # # Simulation execution
        iterations = model.steady_state(max_iterations=max_it, nsteady=1000, sensibility=0.00001, node_status=True, progress_bar=True, drop_evolution=False)
        fig, ax = plt.subplots(figsize=(7, 5), dpi=600)
        evolution(iterations, spaghetti_hex_list, fig=fig, ax=ax)
        plt.title(r'$\epsilon$='+f'{e},'+r'$\gamma$='+f'{g},'+r'$p_m$='+f'{pm}')
        plt.savefig(f"plots/{t}_spaghetti_pm{pm}_e{e}_g{g}.png", bbox_inches="tight")
        plt.close()
        fig, ax = plt.subplots(figsize=(7, 5), dpi=600)
        plt.scatter(x=[i for i in range(n)], y=sorted(list(iterations[len(iterations)-1]['status'].values())))
        plt.ylim(0.0, 1.0)
        plt.title(r'$\epsilon$='+f'{e},'+r'$\gamma$='+f'{g},'+r'$p_m$='+f'{pm}')
        plt.savefig(f"plots/{t}_finalopinions_pm{pm}_e{e}_g{g}.png", bbox_inches="tight")