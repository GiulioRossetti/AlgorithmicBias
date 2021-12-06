include("deffuant.jl")
include("bias.jl")
include("media.jl")
include("functiontest.jl")

using CSV
using DataFrames
using JSON
using LightGraphs
using Statistics

function multiple_runs(f, name, params, nsteady; nruns)
    for nr in 1:nruns
        if isfile("res/$name nr$nr.csv")
            continue
        else
            r =  f(params... ; nsteady=nsteady)
            df = DataFrame(r)
            CSV.write("res/$name nr$nr.csv",  df, header=false)
    end
end

function create_dictionaries(name)
    if isfile("aggregate/final_clusters $name.json")
        final_clusters = read_json("aggregate/final_clusters $name.json")
        final_opinions = read_json("aggregate/final_opinions $name.json")
        final_its = read_json("aggregate/final_iterations $name.json")
    else
        final_clusters = Dict()
        final_opinions = Dict()
        final_its = Dict()
    end
    return final_clusters, final_opinions, final_its
end

function readres(resfile)
    csv_reader = CSV.File(resfile, header=false)
    r = Vector{Any}()
    for row in csv_reader
        opinions=Vector{Float16}()
        for el in row
            append!(opinions, el)
            global ops = Tuple(opinions)
        end
        append!(r, [ops])
    end
    return r
end

function return_dictionaries(f, name, params; nruns)
    final_clusters, final_opinions, final_its = create_dictionaries(name)
    for nr in 1:nruns
        if string(nr) in keys(final_clusters)
            continue
        else
            resfile = "res/$name nr$nr.csv"
            if isfile(resfile)
                r = readres(resfile)
            else
                multiple_runs(f, name, params, nsteady; nruns)
                r = readres(resfile)
            end
        end
        fo = r[size(r)[1]]
        ϵ = params[2]
        clusters = population_clusters([x for x in r[end]], ϵ)
        merge!(final_clusters,Dict(string(nr)=>clusters))
        merge!(final_opinions, Dict(string(nr)=>fo))
        merge!(final_its, Dict(string(nr)=>size(r)[1]))
    end
    return final_opinions, final_clusters, final_its
end

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

function plotting(name; nruns)
    spaghetti=true; finaldist = true
    for nr in 1:nruns
        if isfile("plots/$name nr$nr.png")
            spaghetti = false
        end
        if isfile("plots/final_distribution $name nr$nr.png")
            finaldist = false
        end
        resfile = "res/$name nr$nr.csv"
        if isfile(resfile)
            r = readres(resfile)
            df = DataFrame(r)
            if finaldist
                final_dist_plot(r, "plots/final_distribution $name nr$nr.png")
            end
            if spaghetti
                spaghetti_plot(df, size(r)[1], "plots/$name nr$nr.png")
            end
        else
            continue
        end
    end
end

