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
nruns = 100

for media_op in [[0.0], [0.5], [0.05, 0.95], [0.05, 0.5, 0.95]], pₘ in [0.0, 0.1, 0.2, 0.3, 0.4, 0.5], ϵ in [0.2, 0.3, 0.4, 0.5], γ in [0.0, 0.5, 0.75, 1.0, 1.25, 1.5]
    f = deffuant_bias_media
    mos = join([string(el) for el in media_op], ";", ";")
    params = [g, ϵ, γ, γ, pₘ, media_op, max_t]
    name = "media mo$media_op p$pₘ e$ϵ g$γ gm$γ mi$max_t"
    deleteres(f, name, params; nruns)
end

# for pₘ in [0.0, 0.1, 0.2, 0.3, 0.4, 0.5], ϵ in [0.2, 0.3, 0.4, 0.5], γ in [0.0, 0.5, 0.75, 1.0, 1.25, 1.5]
#     f = deffuant_bias_media
#     media_op = [0.0]
#     mos = join([string(el) for el in media_op], ";", ";")
#     params = [g, ϵ, γ, γ, pₘ, media_op, max_t]
#     name = "media mo$media_op p$pₘ e$ϵ g$γ gm$γ mi$max_t"
#     checkifruns(f, name, params; nruns)
#     # multiple_runs(f, name, params, nsteady; nruns)
#     # final_opinions, final_clusters, final_its = return_dictionaries(f, name, params; nruns)
#     # write_aggregate(name, final_opinions, final_clusters, final_its)
#     # writeaverages(name, params, mos, n, p)
# end

# for pₘ in [0.0, 0.1, 0.2, 0.3, 0.4, 0.5], ϵ in [0.2, 0.3, 0.4, 0.5], γ in [0.0, 0.5, 0.75, 1.0, 1.25, 1.5]
#     f = deffuant_bias_media
#     media_op = [0.05, 0.95]
#     mos = join([string(el) for el in media_op], ";", ";")
#     params = [g, ϵ, γ, γ, pₘ, media_op, max_t]
#     name = "media mo$media_op p$pₘ e$ϵ g$γ gm$γ mi$max_t"
#     # multiple_runs(f, name, params, nsteady; nruns)
#     final_opinions, final_clusters, final_its = return_dictionaries(f, name, params; nruns)
#     write_aggregate(name, final_opinions, final_clusters, final_its)
#     writeaverages(name, params, mos, n, p)
# end