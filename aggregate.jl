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


function nclusters(name, n)
    if isfile("aggregate/final_clusters $name.json")
        open("aggregate/final_clusters $name.json", "r") do f
            global filedict
            filedict = JSON.parse(f)  # parse and transform data
        end
        clusters = keys_to_int(filedict)
        ncarray = []
        for nr in keys(clusters)
            C_num = n*n
            C_den = 0
            for k in keys(clusters[nr])
                C_den += clusters[nr][k]*clusters[nr][k]
            end
            C = C_num / C_den
            append!(ncarray, [C])
        end
        return ncarray
    end
end

function pwdists(name, n)
    if isfile("aggregate/final_opinions $name.json")
        open("aggregate/final_opinions $name.json", "r") do f
            global filedict
            filedict = JSON.parse(f)  # parse and transform data
        end
        opinions = keys_to_int(filedict)
        
        pwdarray = zeros(Float64, length(opinions), n, n)
        for nr in keys(opinions)
            for i in 1:n
                o_i = opinions[nr][i]
                for j in i:n
                    o_j = opinions[nr][j]
                    d = abs.(o_i-o_j)
                    pwdarray[nr, i, j] = d
                end
            end
        end
        return pwdarray
    end
end

function nits(name)
    if isfile("aggregate/final_iterations $name.json")
        open("aggregate/final_iterations $name.json", "r") do f
            global filedict
            filedict = JSON.parse(f)  # parse and transform data
        end
        iterations = keys_to_int(filedict)
        
        itarray = []
        for nr in keys(iterations)
            append!(itarray, iterations[nr])
        end
        return itarray
    end
end

function writeaverages(name, params, mos, n, p)
    nca = nclusters(name, n)
    pwda = pwdists(name, n)
    itsa = nits(name)
    avgnc, stdnc = mean_and_std(nca)
    avgpwd, stdpwd = mean_and_std(pwda) 
    avgnits, stdnits=mean_and_std(itsa)
    ϵ = params[2]
    γ = params[3]
    pₘ = params[5]
    max_t = params[7]
    media_op = params[6]
    string = "$n $p $ϵ $γ $γ $pₘ $max_t $mos $avgnc $stdnc $avgpwd $stdpwd $avgnits $stdnits"
    list = split(string)
    s = join(list, ",")
    f = open("aggregate/averages media $name.csv", "w")
    write(f, s)
    close(f)
end

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
        return final_clusters, final_opinions, final_its
    end

    final_clusters, final_opinions, final_its = create_dictionaries()
    
    for nr in 1:nruns
        if string(nr) in keys(final_clusters)
            continue
        else
            println("run missing from aggregate file: searching for $name nr$nr")
            resfile = "res/$name nr$nr.csv"
            if isfile(resfile)
                println("runfile found: reading results")
                r = readres(resfile)
                println("read results")
            else
                println("Runfile missing: starting new runs")
                multiple_runs(f, name, params, nsteady; nruns)
                println("execution ended")
                r = readres(resfile)
                println("read results")
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

function plotting(name; nruns)
    println("plotting function entered")
    spaghetti=true; finaldist = true
    nr = 1
    if isfile("plots/evolution/$name nr$nr.png")
        println("evolution already plotted")
        spaghetti = false
    end
    if isfile("plots/finaldistribution/final_distribution $name nr$nr.png")
        println("final distribution already plotted")
        finaldist = false
    end
    resfile = "res/$name nr$nr.csv"
    if isfile(resfile)
        println("result file exists")
        r = readres(resfile)
        df = DataFrame(r)
        if finaldist
            println("plotting final opinion distribution")
            final_dist_plot(r, "plots/finaldistribution/final_distribution $name nr$nr.png")
        end
        if spaghetti
            println("plotting evolution")
            spaghetti_plot(df, size(r)[1], "plots/evolution/$name nr$nr.png")
        end   
    end
end

