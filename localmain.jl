include("execution.jl")
include("deffuant.jl")
include("bias.jl")
include("media.jl")
include("aggregate.jl")

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
nr=1

for media_op in [[0.05, 0.5, 0.95]], pₘ in [0.0, 0.5], ϵ in [0.2, 0.3, 0.4, 0.5], γ in [0.0, 0.5, 1.0, 1.5]
    f = deffuant_bias_media
    params = [g, ϵ, γ, γ, pₘ, media_op, max_t]
    name = "media mo$media_op p$pₘ e$ϵ g$γ gm$γ mi$max_t"
    single_run(f, name, params, nsteady; nr)
end
