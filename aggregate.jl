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

# function checkifruns(f, name, params; nruns)
#     # if isfile("aggregate/final_clusters $name.json")
#     #     final_clusters = read_json_cluster("aggregate/final_clusters $name.json")
#     #     final_opinions = read_json("aggregate/final_opinions $name.json")
#     #     final_its = read_json("aggregate/final_iterations $name.json")
#     # else
#     #     println("final_clusters $name.json does not exist")
#     #     return
#     # end

#     # fc = final_clusters
#     # fo = keys_to_int(final_opinions)
#     # fi = keys_to_int(final_its)
#     for nr in 1:nruns
#         # if nr in keys(fc)
#         #     println(nr)
#         #     continue
#         # else
#         # println("missing runs in final_clusters $name.json")
#         resfile = "res/$name nr$nr.csv"
#         if isfile(resfile)
#             continue
#         else
#             println("missing run $name $nr")
#             # multiple_runs(f, name, params, nsteady; nruns)
#         end
#         # end
#     end
# end

function deleteres(f, name, params; nruns)
    try
        global fc = read_json_cluster("aggregate/final_clusters $name.json")
        global fo = keys_to_int(read_json("aggregate/final_opinions $name.json"))
        global fi = keys_to_int(read_json("aggregate/final_iterations $name.json"))
    catch e
        println(e)
        return
    end
    
    for nr in 50:nruns
        resfile = "c:/res/$name nr$nr.csv"
        finalopfile = "c:/res/final_opinions $name nr$nr.csv"
        if nr in keys(fc) && nr in keys(fo) && nr in keys(fi)
            println(">>> run already present in aggregate file...")
            println(">>> removing res file from hard disk...")
            if isfile(resfile)
                rm(resfile)
            end
            if isfile(finalopfile)
                rm(finalopfile)
            end
        else
            if isfile(resfile)
                println(">>> run $nr not present in dictionary but present in res/")
            else
                println(">>> run $nr not present in res/ nor in dictionary")
                continue
            end
        end
    end
end
        
function return_dictionaries(f, name, params; nruns)

    function create_dictionaries()
        if isfile("aggregate/final_clusters $name.json")
            println(">>> aggregate file already exists")
            try
                final_clusters = read_json_cluster("aggregate/final_clusters $name.json")
            catch (e)
                println(e)
            end
        else
            println(">>> aggregate final clusters files not present")
            final_clusters = Dict()
        end

        if isfile("aggregate/final_opinions $name.json")
            println(">>> aggregate file already exists")
            try
                final_opinions = read_json("aggregate/final_opinions $name.json")
            catch (e)
                println(e)
            end
        else
            println(">>> aggregate final opinions files not present")
            final_opinions = Dict()
        end

        if isfile("aggregate/final_iterations $name.json")
            println(">>> aggregate file already exists")
            try
                final_its = read_json("aggregate/final_iterations $name.json")
            catch (e)
                println(e)
            end
        else
            println(">>> aggregate final iterations files not present")
            final_its = Dict()
        end
        println(">>> dictionaries created for $name")
        return final_clusters, keys_to_int(final_opinions), keys_to_int(final_its)
    end

    final_clusters, final_opinions, final_its = create_dictionaries()
    
    fc = final_clusters
    fo = final_opinions
    fi = final_its

    if (length(fc) == nruns) && (length(fi) == nruns) && (length(fo) == nruns)
        println(">>> dictionaries already have all the runs")
        return fo, fc, fi
    else
        for nr in 1:nruns
            if nr in keys(fc) && nr in keys(fo) && nr in keys(fi)
                println(">>> run $nr already present in dictionary")
                continue
            else
                resfile = "res/$name nr$nr.csv"
                if isfile(resfile)
                    println(">>> run $nr not present in dictionary but present in res/")
                    println(">>> reading $name nr$nr.csv file...")
                    r = readres(resfile)
                else
                    println(">>> Execution not performed yet. Do you want to start run?[yes/no]")
                    risp = readline()
                    if risp == "yes"
                        multiple_runs(f, name, params, nsteady; nruns)
                        r = readres(resfile)
                    elseif risp == "no"
                        continue
                    else
                        println(">>> did not understand input, skipping run anyways lol")
                    end
                end
            end
            o = [x for x in r[size(r)[1]]]
            clusters = population_clusters([x for x in r[end]])
            merge!(fc, Dict(nr=>clusters))
            merge!(fo, Dict(nr=>o))
            merge!(fi, Dict(nr=>size(r)[1]))
        end
        println(">>> dictionaries merged with new experiments results")
        return fo, fc, fi
    end
end

function write_aggregate(name, final_opinions, final_clusters, final_its)
    println(">>> writing aggregate files")
    json_string = JSON.json(final_clusters)
    open("aggregate/final_clusters $name.json","w") do file
        write(file, json_string)
    end
    json_string = JSON.json(final_opinions)
    open("aggregate/final_opinions $name.json","w") do file2
        write(file2, json_string)
    end
    json_string = JSON.json(final_its)
    open("aggregate/final_iterations $name.json","w") do file3
        write(file3, json_string)
    end
    println(">>> aggregate files for $name written")
end

function writeaverages(name, params, mos, n, p)
    println(">>> writing averages files")
    nca = nclusters(name, n)
    pwda = pwdists(name, n)
    itsa = nits(name)
    avgnc, stdnc = mean_and_std(nca)
    avgpwd, stdpwd = mean_and_std(pwda) 
    avgnits, stdnits = mean_and_std(itsa)
    ϵ = params[2]; γ = params[3]; pₘ = params[5]; max_t = params[7]
    string = "$n $p $ϵ $γ $γ $pₘ $max_t $mos $avgnc $stdnc $avgpwd $stdpwd $avgnits $stdnits"
    list = split(string)
    s = join(list, ",")
    if isfile("aggregate/averages $name.csv") == false
        open("aggregate/averages $name.csv", "w+") do file
            write(file, s)
        end
        println(">>> averages files for $name written")
    else
        println(">>> averages file already exists...")
    end
end

# function plotting(f, name, params, nsteady, nr; spaghetti::Bool=false, finaldist::Bool=true)
#     # println("plotting $name")
#     if isfile("plots/evolution/$name nr$nr.png")
#         spaghetti = false
#     end
#     if isfile("plots/finaldistribution/final_distribution $name nr$nr.png")
#         finaldist = false
#     end
#     resfile = "res/$name nr$nr.csv"
#     if isfile(resfile)
#         r = readres(resfile)
#         df = DataFrame(r)
#         if finaldist
#             final_dist_plot(r, "plots/finaldistribution/final_distribution $name nr$nr.png")
#         end
#         if spaghetti
#             spaghetti_plot(df, size(r)[1], "plots/evolution/$name nr$nr.png")
#         end   
#     else
#         println("$resfile running")
#         multiple_runs(f, name, params, nsteady; nr)
# #     end
# # end





# # function create_dictionaries()
# #     if isfile("aggregate/final_opinions $name.json")
# #         final_clusters = read_json_cluster("aggregate/final_clusters $name.json")
# #         final_opinions = read_json("aggregate/final_opinions $name.json")
# #         final_its = read_json("aggregate/final_iterations $name.json")
# #         return
# #     else
# #         final_clusters = Dict()
# #         final_opinions = Dict()
# #         final_its = Dict()
# #     end
# #     return final_clusters,final_opinions, final_its
# # end

# function return_final_its_dict(f, name, params; nruns)
#     fi = Dict()
#     println("populating dictionaries for $name")
#     for nr in ProgressBar(1:nruns)
#         if nr in keys(fi)
#             # println(nr)
#             continue
#         else
#             # println("reading res $name nr$nr")
#             if isfile("res/$name nr$nr.csv")
#                 r = readres("res/$name nr$nr.csv")
#             else
#                 continue
#             end
#         end
#         merge!(fi, Dict(nr=>length(r)))
#     end
#     return fi
# end

# function write_final_it_dict(name, final_its)
#     println("writing aggregate files")
#     json_string = JSON.json(final_its)
#     open("aggregate/final_iterations $name.json","w") do f
#         write(f, json_string)
#     end
#     println("done")
# end


# function return_dictionaries(f, name, params; nruns)
   
#     fc = Dict()
#     fo = Dict()
#     fi = Dict()
    
#     println("populating dictionaries for $name")
#     for nr in ProgressBar(1:nruns)
#         if isfile("res/$name nr$nr.csv")
#             r = readres("res/$name nr$nr.csv")
#         end
#         o = [x for x in (r[end])]
#         clusters = population_clusters(o)
#         merge!(fc,Dict(nr=>clusters))
#         merge!(fo, Dict(nr=>o))
#         merge!(fi, Dict(nr=>length(r)))
#     end

#     return fo, fc, fi

# end


# function write_finalops(name, final_opinions)
#     json_string = JSON.json(final_opinions)
#     open("aggregate/final_opinions $name.json","w") do f
#         write(f, json_string)
#     end
#     println("done")
# end

# function write_aggregate(name, final_opinions, final_clusters, final_its)
#     println("writing aggregate files")
#     json_string = JSON.json(final_clusters)
#     open("aggregate/final_clusters $name.json","w") do f
#         write(f, json_string)
#     end
#     json_string = JSON.json(final_opinions)
#     open("aggregate/final_opinions $name.json","w") do f
#         write(f, json_string)
#     end
#     json_string = JSON.json(final_its)
#     open("aggregate/final_iterations $name.json","w") do f
#         write(f, json_string)
#     end
#     println("done")
# end

# function writeaveragesmedia(name, params, mos, n, p)
#     nca = nclusters(name, n)
#     pwda = pwdists(name, n)
#     itsa = nits(name)
#     # entra = entropy(name) 
#     avgnc, stdnc = avg_and_std(nca)
#     avgpwd, stdpwd = avg_and_std(pwda) 
#     avgnits, stdnits = avg_and_std(itsa)
#     ϵ = params[2]; γ = params[3]; pₘ = params[5]; max_t = params[7]
#     string = "$n $p $ϵ $γ $γ $pₘ $max_t $mos $avgnc $stdnc $avgpwd $stdpwd $avgnits $stdnits"
#     list = split(string)
#     s = join(list, ",")
#     f = open("D:/aggregate/averages media $name.csv", "w")
#     write(f, s)
#     close(f)
# end

# function writeaveragesbiasrewiring(name, params, graphname, n, p)
#     nca = nclusters(name, n)
#     pwda = pwdists(name, n)
#     itsa = nits(name)
#     avgnc, stdnc = avg_and_std(nca)
#     avgpwd, stdpwd = avg_and_std(pwda) 
#     avgnits, stdnits = avg_and_std(itsa)
#     ϵ = params[2]; γ = params[3]; gr = params[4]; pr = params[5]; max_t = params[6];
#     string = "$graphname $n $p $ϵ $γ $gr $pr $max_t $avgnc $stdnc $avgpwd $stdpwd $avgnits $stdnits"
#     list = split(string)
#     s = join(list, ",")
#     if isfile("D:/aggregate/new/averages $name.csv") == false
#         open("D:/aggregate/new/averages $name.csv", "w") do f
#             write(f, s)
#         end
#     end
# end

# function plotting(f, name, params, nsteady, nr; spaghetti::Bool=false, finaldist::Bool=true)
#     # println("plotting $name")
#     if isfile("plots/evolution/$name nr$nr.png")
#         spaghetti = false
#     end
#     if isfile("plots/finaldistribution/final_distribution $name nr$nr.png")
#         finaldist = false
#     end
#     resfile = "res/$name nr$nr.csv"
#     if isfile(resfile)
#         r = readres(resfile)
#         df = DataFrame(r)
#         if finaldist
#             final_dist_plot(r, "plots/finaldistribution/final_distribution $name nr$nr.png")
#         end
#         if spaghetti
#             spaghetti_plot(df, size(r)[1], "plots/evolution/$name nr$nr.png")
#         end   
#     else
#         println("$resfile running")
#         multiple_runs(f, name, params, nsteady; nr)
#     end
# end




