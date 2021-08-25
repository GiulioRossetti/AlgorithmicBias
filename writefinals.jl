include("execution.jl")
include("deffuant.jl")
include("bias.jl")
include("media.jl")
include("analysis.jl")

using CSV
using DataFrames
using JSON
using LightGraphs

# Graph initialization
n = 100
p = 1.0
g = erdos_renyi(n, p)

# simulation global parameters
max_t = 1000000
nsteady = 1000

media_op = [0.00]
mos = join([string(el) for el in media_op], ";", ";")

#Writing averages csv
for pₘ in [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 1.0], ϵ in [0.1, 0.2, 0.3, 0.4, 0.5, 1.0], γ in [0.0, 0.25, 0.5, 0.75, 1.25, 1.5]
            name = "media mo$media_op p$pₘ e$ϵ g$γ gm$γ mi$max_t"
            paramvalues = "$n $p $ϵ $γ $γ $pₘ $max_t $mos"
            isfile("aggregate/averages $name.csv") ? continue : if isfile("aggregate/final_clusters $name.json") ? writeaverages(name, paramvalues, n) : continue            
end