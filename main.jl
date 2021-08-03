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
    println("starting $nruns runs for params = $params")
    for nr in 1:nruns
        println("run $nr")
        r =  f(params... ; nsteady=nsteady)
        df = DataFrame(r)
        #println(experiment_name)
        CSV.write("res/$name nr$nr.csv",  df, header=false)
        spaghetti_plot(df, size(r)[1], "plots/$name nr$nr.png")

        # aggregate stats
        fo = r[size(r)[1]]
        ϵ = params[2]
        clusters = population_clusters([x for x in r[end]], ϵ)
        append!(final_clusters, clusters)
        append!(finalops, [fo])
    end
    println("ending $nruns runs for params = $params")

    return finalops, final_clusters
end

#################################


# Graph initialization
n = 100
p = 1.0
g = erdos_renyi(n, p)

# simulation global parameters
max_t = 1000000
nsteady = 1000


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

# Example Media
media_op = [0.05, 0.5, 0.95]
for ϵ in [0.5, 0.3, 0.2], γ in [0, 0.5, 0.75, 1, 1.25, 1.5], γₘ in  [0, 0.5, 0.75, 1, 1.25, 1.5],  pₘ in [0.0, 0.2, 0.4, 0.6, 0.7, 0.8, 0.9, 1.0]
    params = [g, ϵ, γ, γₘ, pₘ, media_op, max_t]
    name = "media e$ϵ g$γ gm$γ p$pₘ mi$max_t"
    final_opinions, final_clusters = multiple_runs(deffuant_bias_media, name, params, nsteady; nruns=100)
    write_aggregate(name, final_opinions, final_clusters)
end
