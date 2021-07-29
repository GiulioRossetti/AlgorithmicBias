include("deffuant.jl")
include("bias.jl")
include("media.jl")

using CSV
using DataFrames
using JSON
using LightGraphs

function write_aggregate(name, final_opinions, final_clusters)

    df = DataFrame(final_opinions)
    CSV.write("aggregate/final_opinions $name.txt",  df, header=false)

    json_string = JSON.json(final_clusters)
    open("aggregate/final_clusters $name.json","w") do f
        write(f, json_string)
    end
end

function multiple_runs(f, name, params, nsteady; nruns)
    finalops = []
    final_clusters = []
    for nr in 1:nruns
        r =  f(params... ; nsteady=nsteady)
        df = DataFrame(r)
        #println(experiment_name)
        CSV.write("res/$name.csv",  df, header=false)
        spaghetti_plot(df, size(r)[1], "plots/$name.png")

        # aggregate stats
        fo = r[size(r)[1]]
        ϵ = params[2]
        clusters = population_clusters([x for x in r[end]], ϵ)
        append!(final_clusters, clusters)
        append!(finalops, [fo])
    end
    return finalops, final_clusters
end

#################################


# Graph initialization
n = 250
p = 1.0
g = erdos_renyi(n, p)

# simulation global parameters
max_t = 100
nsteady = 50


# Example Deffuant
for ϵ in [0.1, 0.2, 0.3, 0.4]
    params = [g, ϵ, max_t]
    name = "deffuant e$ϵ mi$max_t"
    final_opinions, final_clusters = multiple_runs(deffuant, name, params, nsteady; nruns=10)
    write_aggregate(name, final_opinions, final_clusters)
end


# Example Bias
for ϵ in [0.1, 0.2, 0.3, 0.4], γ in [0, 1, 1.5, 2]
    name = "bias e$ϵ g$γ mi$max_t"
    params = [g, ϵ, γ, max_t]
    final_opinions, final_clusters = multiple_runs(deffuant_bias, name, params, nsteady; nruns=10)
    write_aggregate(name, final_opinions, final_clusters)
end

# Example Media
media_op = [0.1, 0.5, 0.9]
for ϵ in [0.1, 0.2, 0.3, 0.4], γ in [0, 1, 1.5, 2], γₘ in  [0, 1, 1.5, 2],  pₘ in [0.1, 0.2, 0.3, 0.4]
    params = [g, ϵ, γ, γₘ, pₘ, media_op, max_t]
    name = "media e$ϵ g$γ gm$γ p$pₘ mi$max_t"
    final_opinions, final_clusters = multiple_runs(deffuant_bias_media, name, params, nsteady; nruns=10)
    write_aggregate(name, final_opinions, final_clusters)
end
