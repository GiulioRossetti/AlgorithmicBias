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

function return_dictionaries(f, name, params; nruns)

    function create_dictionaries()
        if isfile("aggregate/final_clusters $name.json")
            final_clusters = read_json("aggregate/final_clusters $name.json")
            final_opinions = read_json("aggregate/final_opinions $name.json")
            final_its = read_json("aggregate/final_iterations $name.json")
        else
            final_clusters = Dict()
            final_opinions = Dict()
            final_its = Dict()
        end
        return keys_to_int(final_clusters), keys_to_int(final_opinions), keys_to_int(final_its)
    end

    final_clusters, final_opinions, final_its = create_dictionaries()
    
    for nr in 1:nruns
        if nr in keys(final_clusters)
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
        merge!(final_clusters,Dict((nr)=>clusters))
        merge!(final_opinions, Dict((nr)=>fo))
        merge!(final_its, Dict((nr)=>size(r)[1]))
    end
    return final_opinions, final_clusters, final_its
end

function write_aggregate(name, final_opinions, final_clusters, final_its)
    println("writing aggregate files")
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
    println("done")
end

function writeaverages(name, params, mos, n, p)
    nca = nclusters(name, n)
    pwda = pwdists(name, n)
    itsa = nits(name)
    entra = entropy(name) 
    avgnc, stdnc = mean_and_std(nca)
    avgpwd, stdpwd = mean_and_std(pwda) 
    avgnits, stdnits = mean_and_std(itsa)
    avgentr, stdentr = mean_and_std(entra)
    ϵ = params[2]; γ = params[3]; pₘ = params[5]; max_t = params[7]
    string = "$n $p $ϵ $γ $γ $pₘ $max_t $mos $avgnc $stdnc $avgpwd $stdpwd $avgnits $stdnits $avgentr $stdentr"
    list = split(string)
    s = join(list, ",")
    f = open("aggregate/averages media $name.csv", "w")
    write(f, s)
    close(f)
end

function plotting(name; nruns)
    println("plotting function entered")
    spaghetti=true; finaldist = true
    nr = 1
    if isfile("plots/evolution/$name nr$nr.png")
        spaghetti = false
    end
    if isfile("plots/finaldistribution/final_distribution $name nr$nr.png")
        finaldist = false
    end
    resfile = "res/$name nr$nr.csv"
    if isfile(resfile)
        r = readres(resfile)
        df = DataFrame(r)
        if finaldist
            final_dist_plot(r, "plots/finaldistribution/final_distribution $name nr$nr.png")
        end
        if spaghetti
            spaghetti_plot(df, size(r)[1], "plots/evolution/$name nr$nr.png")
        end   
    end
end




