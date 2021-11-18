include("deffuant.jl")
include("bias.jl")
include("media.jl")

using CSV
using DataFrames
using JSON
using LightGraphs
using Statistics

function write_aggregate(name, final_opinions, final_clusters, final_its)
    json_string = JSON.json(final_clusters)
    open("aggregate/final_clusters $name.json","w") do f
        write(f, json_string)
    end

    json_string = JSON.json(final_opinions)
    open("aggregate/final_opinions $name.json","w") do f
        write(f, json_string)
    end

    json_string = JSON.json(final_its)
    open("aggregate/final_iterations $name.json","w") do f
        write(f, json_string)
    end

end

function multiple_runs(f, name, params, nsteady; nruns)
    final_opinions = Dict()
    final_clusters = Dict()
    final_its = Dict()
    println("starting $nruns runs for params = $params")
    for nr in 1:nruns
        r =  f(params... ; nsteady=nsteady)
        df = DataFrame(r)
        CSV.write("res/$name nr$nr.csv",  df, header=false)
        # aggregate stats
        fo = r[size(r)[1]]
        ϵ = params[2]
        clusters = population_clusters([x for x in r[end]], ϵ, "plots/final_distribution $name nr$nr.png")
        merge!(final_clusters,Dict(nr=>clusters))
        merge!(final_opinions, Dict(nr=>fo))
        merge!(final_its, Dict(nr=>size(r)[1]))
        spaghetti_plot(df, size(r)[1], "plots/$name nr$nr.png")
    end
    return final_opinions, final_clusters, final_its
end

