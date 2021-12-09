import seaborn as sns
import matplotlib.pyplot as plt
sns.set_style("whitegrid")
import networkx as nx
import ndlib.models.ModelConfig as mc
import warnings
warnings.filterwarnings("ignore")
import ndlib.models.ModelConfig as mc
from ndlib.viz.mpl.OpinionEvolution import OpinionEvolution
import ndlib.models.opinions as op
import os

# leggere parametri parsando il nome del file?????
def restoiterations(filename):   
    iterations = list()
    try:
        infile = open(filename, "r")
        lines = infile.readlines()
        for i,line in enumerate(lines):
            opinions = list(line.split(','))
            itdict = {"iteration":i, "status":{k: float(v) for k, v in enumerate(opinions)},"node_count":{0:0},"status_delta":{0:0}}
            iterations.append(itdict)
    except FileNotFoundError:
        pass
    return iterations

def spaghetti(e,p,g,fig,ax,quale=None):
    try:
        graph = nx.complete_graph(100)
        model = op.AlgorithmicBiasMediaModel(graph) 
        config = mc.Configuration()
        config.add_model_parameter("p", p)
        config.add_model_parameter("k", 3)
        config.add_model_parameter("epsilon", e)
        config.add_model_parameter("gamma", g)
        config.add_model_parameter("gamma_media",g)
        model.set_initial_status(config)
        model.set_media_opinions([0.05, 0.5, 0.95])
    except Exception as err:
        pass
    nr=1
    while True:
        iterations = restoiterations("res/onemedia/media mo[0.0] p{} e{} g{} gm{} mi1000000 nr{}".format(p,e,g,g,nr))
        if len(iterations)>0:
            viz = OpinionEvolution(model, iterations)
            viz.plot(fig, ax)
            break
        else:
            nr+=1

def spaghettigrid(p):
    fig, axes = plt.subplots(nrows=3, ncols=5, figsize=(6, 3), dpi=600, sharey=True)
    row=0
    for e in [0.2, 0.3, 0.5]:
        col=0
        for g in [0.0, 0.5, 0.75, 1.0, 1.5]: 
            spaghetti(e,p,g,fig,ax=axes[row,col],quale='onemedia')
            col+=1
            # pbar.update(1)
        row+=1

import time
start = time.time()
# mpl.rcParams["text.usetex"] = True
plt.rc('font',weight='bold',**{'family':'serif', 'size':6, 'serif':['Computer Modern Roman']})
for p in [0.1, 0.2, 0.3, 0.4, 0.5]:
    spaghettigrid(p=p)

print("process lasted {} seconds".format(time.time()-start))