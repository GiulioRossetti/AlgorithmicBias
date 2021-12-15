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
nruns = 100

# Make plots: forse i plot meglio farli dopo con python che mi vengono meglio
for pₘ in [0.0, 0.1, 0.2, 0.3, 0.4, 0.5], ϵ in [0.1, 0.2, 0.3, 0.4, 0.5, 1.0], γ in [0.0, 0.25, 0.5, 0.75, 1.0, 1.25, 1.5]    
    f = deffuant_bias_media
    media_op = [0.0]
    mos = join([string(el) for el in media_op], ";", ";")
    println("plotting process started")
    params = [g, ϵ, γ, γ, pₘ, media_op, max_t]
    name = "media mo$media_op p$pₘ e$ϵ g$γ gm$γ mi$max_t"
    plotting(f,name,params,nsteady; nr=1)
end