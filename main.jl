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
    its = []
    println("starting $nruns runs for params = $params")
    for nr in 1:nruns
        r =  f(params... ; nsteady=nsteady)
        df = DataFrame(r)
        CSV.write("res/$name nr$nr.csv",  df, header=false)
        spaghetti_plot(df, size(r)[1], "plots/$name nr$nr.png")
        append!(its,size(r)[1])
        # aggregate stats
        fo = r[size(r)[1]]
        ϵ = params[2]
        clusters = population_clusters([x for x in r[end]], ϵ)
        append!(final_clusters, clusters)
        append!(finalops, [fo])
    end
    itsfile = open("aggregate/num it $name.txt", "w")
    avg_niter = sum(its)/size(its)[1]
    write(itsfile, "$avg_niter")
    close(itsfile)
    return finalops, final_clusters
end