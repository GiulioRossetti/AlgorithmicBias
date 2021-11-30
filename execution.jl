include("deffuant.jl")
include("bias.jl")
include("media.jl")
include("functiontest.jl")

using CSV
using DataFrames
using JSON
using LightGraphs
using Statistics

function write_aggregate(name, final_opinions, final_clusters, final_its)
    json_string = JSON.json(final_clusters)
    open("aggregate/final_clusters $name stofacendoleprove.json","w") do f
        write(f, json_string)
    end
    json_string = JSON.json(final_opinions)
    open("aggregate/final_opinions $name stofacendoleprove.json","w") do f
        write(f, json_string)
    end
    json_string = JSON.json(final_its)
    open("aggregate/final_iterations $name stofacendoleprove.json","w") do f
        write(f, json_string)
    end

end

function multiple_runs(f, name, params, nsteady; nruns)
    if isfile("aggregate/final_clusters $name.json")
        final_clusters = read_json("aggregate/final_clusters $name.json")
        final_opinions = read_json("aggregate/final_opinions $name.json")
        final_its = read_json("aggregate/final_iterations $name.json")
    else
        final_clusters = Dict()
        final_opinions = Dict()
        final_its = Dict()
    end
    runsdone = length(final_clusters) + 1
    println("starting $nruns-$runsdone runs for params = $params")
    for nr in runsdone:nruns
        #se ho già fatto 100 run non fa niente e ritorna i dizionari
        #altrimenti dovrebbe fare le run mancanti e aggiungerle ai dizionari e poi ritornare i dizionari
        r =  f(params... ; nsteady=nsteady)
        df = DataFrame(r)
        CSV.write("res/$name nr$nr.csv",  df, header=false)
        fo = r[size(r)[1]]
        ϵ = params[2]
        clusters = population_clusters([x for x in r[end]], ϵ, "plots/final_distribution $name nr$nr.png")
        merge!(final_clusters,Dict(string(nr)=>clusters))
        merge!(final_opinions, Dict(string(nr)=>fo))
        merge!(final_its, Dict(string(nr)=>size(r)[1]))
        spaghetti_plot(df, size(r)[1], "plots/$name nr$nr.png")
    end
    return final_opinions, final_clusters, final_its
end

