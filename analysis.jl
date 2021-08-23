using JSON
using Statistics
using CSV
using Tables

function keys_to_int(dict)
    newdict = Dict([parse(Int, string(key)) => val for (key, val) in pairs(dict)])
    return newdict
end

function nclusters(name, n)
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
    f = open("aggregate/enc $name.csv", "w")
    s = join([string(el) for el in ncarray], ",")
    write(f, s)
    close(f)
    return ncarray
end

function pwdists(name, n)
    open("aggregate/final_opinions $name.json", "r") do f
        global filedict
        filedict = JSON.parse(f)  # parse and transform data
    end
    opinions = keys_to_int(filedict)
    
    pwdarray = zeros(Float16, length(opinions), n, n)
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
    # f = open("aggregate/pwdss $name.csv", "w")
    # s = join([string(mean(el)) for row in pwdarray], ",")
    # write(f, s)
    # close(f)
    return pwdarray
end

function nits(name)
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

function mean_and_std(array)
    return mean(array), std(array)
end

function writeaverages(name, paramvalues, n)
    nca = nclusters(name, n)
    pwda = pwdists(name, n)
    itsa = nits(name)
    avgnc, stdnc = mean_and_std(nca)
    avgpwd, stdpwd = mean_and_std(pwda) 
    avgnits, stdnits=mean_and_std(itsa)
    string = paramvalues * " $avgnc $stdnc $avgpwd $stdpwd $avgnits $stdnits"
    list = split(string)
    s = join(list, ", ")
    header = "n,eps,gam,gam_media,p_media,max_it,media_ops,avg_nc,std_nc,avg_pwdist,std_pwdist,avg_niter,std_niter\n"
    f = open("aggregate/averages $name.csv", "w")
    write(f, header)
    write(f, s)
    close(f)
        
        
end
