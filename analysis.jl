using JSON
using Statistics
using CSV
using Tables

function keys_to_int(dict)
    newdict = Dict([parse(Int, string(key)) => val for (key, val) in pairs(dict)])
    return newdict
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
        f = open("aggregate/enc $name.csv", "w")
        s = join([string(el) for el in ncarray], ",")
        write(f, s)
        close(f)
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

function mean_and_std(array)
    return mean(array), std(array)
end

function create_averages_file()
    header = "n,p,eps,gam,gam_media,p_media,max_it,media_ops,avg_nc,std_nc,avg_pwdist,std_pwdist,avg_niter,std_niter\n"
    f = open("aggregate/averages media complete.csv", "a")
    write(f, header)
    close(f)
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
    f = open("aggregate/averages media complete.csv", "a")
    write(f, s)
    close(f)
end
