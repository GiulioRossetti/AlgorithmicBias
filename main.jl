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

media_op = [0.05, 0.5, 0.95]
mos = join([string(el) for el in media_op], ";", ";")

# Example Media
create_averages_file()
for pₘ in [0.1, 0.2, 0.3, 0.4, 0.5, 0.0], ϵ in [0.1, 0.2, 0.3, 0.4, 0.5, 1.0], γ in [0.0, 0.25, 0.5, 0.75, 1.0, 1.25, 1.5]
    params = [g, ϵ, γ, γ, pₘ, media_op, max_t]
    name = "media mo$mos p$pₘ e$ϵ g$γ gm$γ mi$max_t"
    if isfile("aggregate/averages $name.json")
        continue
    else
        final_opinions, final_clusters, final_its =  multiple_runs(deffuant_bias_media, name, params, nsteady; nruns=1)
        write_aggregate(name, final_opinions, final_clusters, final_its)
        writeaverages(name, params, mos, n, p)
    end
end












# # Example Deffuant
# for ϵ in [0.1, 0.2, 0.3, 0.4]
#     params = [g, ϵ, max_t]
#     name = "deffuant e$ϵ mi$max_t"
#     final_opinions, final_clusters = multiple_runs(deffuant, name, params, nsteady; nruns=10)
#     write_aggregate(name, final_opinions, final_clusters)
# end


# # Example Bias
# for ϵ in [0.2], γ in [0, 1, 1.5, 2]
#     name = "bias e$ϵ g$γ mi$max_t"
#     params = [g, ϵ, γ, max_t]
#     final_opinions, final_clusters, final_its = multiple_runs(deffuant_bias, name, params, nsteady; nruns=1)
#     write_aggregate(name, final_opinions, final_clusters, final_its)
# end
