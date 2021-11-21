include("execution.jl")
include("deffuant.jl")
include("bias.jl")
include("media.jl")
include("analysis.jl")

ENV["GKSwstype"]="nul"

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

# Example Media
create_averages_file()
for pₘ in [0.0, 0.1, 0.3, 0.5], ϵ in [0.2, 0.3, 0.5], γ in [0.0, 0.25, 0.5, 0.75, 1.0, 1.25, 1.5]
    params = [g, ϵ, γ, γ, pₘ, media_op, max_t]
    name = "media mo$media_op p$pₘ e$ϵ g$γ gm$γ mi$max_t"
    if isfile("aggregate/final_clusters $name.json")
        continue
    else
        final_opinions, final_clusters, final_its =  multiple_runs(deffuant_bias_media, name, params, nsteady; nruns=100)
        write_aggregate(name, final_opinions, final_clusters, final_its)
        writeaverages(name, params, n, p)
    end
end
