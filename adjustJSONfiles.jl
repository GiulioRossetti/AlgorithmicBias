using JSON
using Statistics
using CSV
using Tables
using DataFrames
using LightGraphs


include("deffuant.jl")
include("bias.jl")
include("media.jl")
include("utils.jl")
include("execution.jl")


function keys_to_int(dict)
    newdict = Dict([parse(Int, string(key)) => val for (key, val) in pairs(dict)])    
    return newdict
end

function splitstring(s)
    v = split(s, r"\(|\)")
    n1 = parse(Float16, v[3])
    n2 =  parse(Float16, v[5])
    return Tuple([Float16(n1), Float16(n2)])
end

function keys_to_tuple(dict)
    newdict = Dict([splitstring(key) => val for (key, val) in pairs(dict)])    
    return newdict
end

function read_json(filename)
    inDict = JSON.parsefile(filename)
    return inDict
end

function read_json_cluster(filename)
    inDict = JSON.parsefile(filename)
    newdict = keys_to_int(inDict)
    newnewdict = Dict()
    for nr in keys(newdict)
        newnewdict[nr] = Dict()
        dicttoadd = keys_to_tuple(newdict[nr])
        newnewdict[nr] = dicttoadd
    end
    return newnewdict
end


function return_dictionaries(f, name, params; nruns)

    function create_dictionaries()
        if isfile("aggregate/final_clusters $name.json")
            final_clusters = read_json_cluster("aggregate/final_clusters $name.json")
            final_opinions = read_json("aggregate/final_opinions $name.json")
            final_its = read_json("aggregate/final_iterations $name.json")
        else
            final_clusters = Dict()
            final_opinions = Dict()
            final_its = Dict()
        end
        return final_clusters,final_opinions, final_its
    end

    final_clusters, final_opinions, final_its = create_dictionaries()
    
    fc = final_clusters
    fo = final_opinions
    fi = final_its

    for nr in 1:nruns
        if nr in keys(fc)
            println(nr)
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
        o = list(r[size(r)[1]])
        clusters = population_clusters([x for x in r[end]])
        merge!(fc,Dict(nr=>clusters))
        merge!(fo, Dict(nr=>o))
        merge!(fi, Dict(nr=>size(r)[1]))
    end
    return fo, fc, fi
end

