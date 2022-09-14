using DataFrames
using Plots
using CSV
using JSON
using LightGraphs
using Statistics
# using PyCall

# np = pyimport("numpy")
# stats = pyimport("scipy.stats")

function keys_to_int(dict)
    newdict = Dict([parse(Int, string(key)) => val for (key, val) in pairs(dict)])    
    return newdict
end

function splitstring(s)
    #     println("string=$s")
        v = split(s, r"\(|\)| ")
        nums = []
        for i = 1:length(v)
            try
                n = parse(Float16, v[i])
                append!(nums, n)
            catch ArgumentError
                continue
            end
        end
    #     println("nums=$nums")
        return Tuple([Float16(nums[1]), Float16(nums[2])])
    end

function keys_to_tuple(dict)
    newdict = Dict([splitstring(key) => val for (key, val) in pairs(dict)])    
    return newdict
end

function read_json(filename)
    inDict = JSON.parsefile(filename, use_mmap=false)
    return inDict
end

function read_json_cluster(filename)
    #leggo il json con i cluster
    inDict = JSON.parsefile(filename, use_mmap=false)
    #trasformo le chiavi (nr) in interi
    newdict = keys_to_int(inDict)
    #creo un dizionario vuoto
    newnewdict = Dict()
    for nr in keys(newdict)
        #per ogni chiave creo un dizionario vuoto dentro l'altro dizionario vuoto
        # newnewdict[nr] = Dict()
        #aggiungo il dizionario corrispondente alla nr con le chiavi trasformate da stringhe a tuple
        dicttoadd = keys_to_tuple(newdict[nr])
        newnewdict[nr] = dicttoadd
    end
    return newnewdict
end

function readres(resfile)
    csv_reader = CSV.File(resfile, header=false)
    r = Vector{Any}()
    for row in csv_reader
        try
            opinions=Vector{Float16}()
            for el in row
                append!(opinions, el)
                global ops = Tuple(opinions)
            end
            append!(r, [ops])
        catch
            continue
        end
    end
    return r
end

is_steady(a, b, toll=0.001) = all([x <= toll for x in abs.(a - b)])

function avg_and_std(array)
    return mean(array), std(array)
end

function spaghetti_plot(df, max_t, filename)
    p = plot(1:max_t, df[!, 1], legend = false, color="#ffffff", ylims = (0,1), xlabel="Iterations", ylabel="Opinions")
    for i in 1:n
        if df[!, i][1] <= 0.33
            plot!(p, 1:max_t, df[!, i], color="#ff0000")
        elseif 0.33 < df[!, i][1] <= 0.66
            plot!(p, 1:max_t, df[!, i], color="#00ff00")
        else
            plot!(p, 1:max_t, df[!, i], color="#0000ff")
        end
    end
    savefig(filename)
end

function final_dist_plot(r, filename)
    x = 1:100 
    r = [x for x in r[end]]
    sort!(r)
    plot(x, r, seriestype = :scatter, color="blue",  xlabel="Nodes", ylabel="Opinions")
    plot!(xlims=(0,101), ylims=(0.0, 1.0))
    savefig(filename)
end

# function population_clusters(data, ϵ)
#     sort!(data)
#     start:: Float16 = data[1]
#     max_val:: Float16 = start + ϵ
#     c = (start::Float16, Float16(max_val))
#     cluster = Dict()
#     for i in data
#         if i <= max_val
#             if c in keys(cluster)
#                 push!(cluster, c => cluster[c]+1)
#             else
#                 push!(cluster, c => 1)
#             end
#         else
#             max_val = Float16(i + ϵ)
#             c = (i::Float16, Float16(max_val))
#             push!(cluster, c => 1)
#         end
#     end
#     return cluster
# end

# function population_clusters(data, ϵ)
#     sort!(data)
#     start = data[1]
#     max_val = start + ϵ
#     c = (start, max_val)
#     cluster = Dict()
#     for i in data
#         if i <= max_val
#             if c in keys(cluster)
#                 push!(cluster, c => cluster[c]+1)
#             else
#                 push!(cluster, c => 1)
#             end
#         else
#             max_val = i + ϵ
#             c = (i, max_val)
#             push!(cluster, c => 1)
#         end
#     end
#     return cluster
# end

function population_clusters(data, threshold=0.01)
    sort!(data)
    start = data[1]
    max_val = start + Float16(threshold)
    max_val = Float16(max_val)
    c = (start, max_val)
    cluster = Dict()
    for i in data
        if i <= max_val
            if c in keys(cluster)
                push!(cluster, c => cluster[c]+1)
            else
                push!(cluster, c => 1)
            end
        else
            max_val = i + threshold
            max_val = Float16(max_val)
            c = (i, max_val)
            push!(cluster, c => 1)
        end
    end
    return cluster
end

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
    else
        println("file not found $name")
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

# function entropy(name)
#     if isfile("aggregate/final_opinions $name.json")
#         infile = open("aggregate/final_opinions $name.json")
#         filedict = read_json(infile)        
#         fodict = keys_to_int(filedict)
#         entropy_arr = []
#         for nr in keys(fodict)
#             opinions = list(filedict[nr])
#             bincount= np.histogram(opinions, bins = np.linspace(0, 1, 11))
#             probabilities = bincount/100
#             entr = stats.entropy(probabilities)
#             append(entropy_arr, entr)
#         end
#         return entropy_arr
#     end
# end
