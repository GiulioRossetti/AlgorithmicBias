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
n = 10
p = 1.0
g = erdos_renyi(n, p)

# simulation global parameters
max_t = 1000000
nsteady = 1000
nruns = 15

# Prova file che non esiste -> nruns tutte ancora da fare, non ci sono res file, non ci sono aggregate file: sembrerebbe ok


# Prova 10 runs / 10 runs fatte -> file aggregato da creare, ancora inesistente: sembrerebbe ok, se il file c'è ed è completo non fa nulla top

#ora aumento nruns a 13 dovrebbe eseguire altre tre run e poi basta: fa le run tutto ok

#prova file aggregato esiste ma ci sono file run già esistenti ma non inseriti nell'aggregate: tutto ok

#prova file aggregato esiste ma mancano delle run (non ci sono run files): sembra tutto ok
# for pₘ in [0.1], ϵ in [0.2], γ in [0.7]
#     f = deffuant_bias_media
#     media_op = [0.0]
#     mos = join([string(el) for el in media_op], ";", ";")
#     params = [g, ϵ, γ, γ, pₘ, media_op, max_t]
#     name = "media mo$media_op p$pₘ e$ϵ g$γ gm$γ mi$max_t"
#     multiple_runs(f, name, params, nsteady; nruns=nruns)
#     final_opinions, final_clusters, final_its = return_dictionaries(f, name, params; nruns)
#     write_aggregate(name, final_opinions, final_clusters, final_its)
# end

# #Populate aggregate folder
# for pₘ in [0.1], ϵ in [0.2], γ in [0.0]
#     params = [g, ϵ, γ, γ, pₘ, media_op, max_t]
#     name = "media mo$media_op p$pₘ e$ϵ g$γ gm$γ mi$max_t"
#     final_opinions, final_clusters, final_its = return_dictionaries(f, name, params; nruns)
#     write_aggregate(name, final_opinions, final_clusters, final_its)

#Make plots
for pₘ in [0.1], ϵ in [0.2], γ in [0.7]
    media_op = [0.0]
    mos = join([string(el) for el in media_op], ";", ";")
    println("plotting process started")
    params = [g, ϵ, γ, γ, pₘ, media_op, max_t]
    name = "media mo$media_op p$pₘ e$ϵ g$γ gm$γ mi$max_t"
    plotting(name; nruns)
end