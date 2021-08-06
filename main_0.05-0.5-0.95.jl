include("main.jl")
include("deffuant.jl")
include("bias.jl")
include("media.jl")

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

media_op = [0.05, 0.5, 0.95]

# Example Media
for ϵ in [1.0, 0.5, 0.4, 0.3, 0.2], γ in [0, 0.5, 0.75, 1, 1.25, 1.5], pₘ in [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]
    params = [g, ϵ, γ, γ, pₘ, media_op, max_t]
    name = "media e$ϵ g$γ gm$γ p$pₘ mi$max_t"
    final_opinions, final_clusters = multiple_runs(deffuant_bias_media, name, params, nsteady; nruns=1)
    write_aggregate(name, final_opinions, final_clusters)
end













# # Example Deffuant
# for ϵ in [0.1, 0.2, 0.3, 0.4]
#     params = [g, ϵ, max_t]
#     name = "deffuant e$ϵ mi$max_t"
#     final_opinions, final_clusters = multiple_runs(deffuant, name, params, nsteady; nruns=10)
#     write_aggregate(name, final_opinions, final_clusters)
# end


# # Example Bias
# for ϵ in [0.1, 0.2, 0.3, 0.4], γ in [0, 1, 1.5, 2]
#     name = "bias e$ϵ g$γ mi$max_t"
#     params = [g, ϵ, γ, max_t]
#     final_opinions, final_clusters = multiple_runs(deffuant_bias, name, params, nsteady; nruns=10)
#     write_aggregate(name, final_opinions, final_clusters)
# end