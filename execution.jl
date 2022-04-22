include("deffuant.jl")
include("bias.jl")
include("media.jl")
include("utils.jl")

using CSV
using DataFrames
using JSON
using LightGraphs
using Statistics

function multiple_runs(f, name, params, nsteady; nruns)
    file = open("logfile.txt") 
    files = readlines(file)
    close(file)
    for nr in 1:nruns
        if "$name nr$nr" in files
            # println("execution number $nr already present for params: $params -> skipping run $nr")
            continue
        else
            println("execution number $nr missing for params: $params -> starting run $nr")
            r =  f(params... ; nsteady=nsteady)
            df = DataFrame(r)
            CSV.write("res/$name nr$nr.csv",  df, header=false)
            CSV.write("res/final_opinions $name nr$nr.csv",  Tables.table([el for el in r[size(r)[1]]]), header=false, delim=',')
            open("logfile.txt", "a+") do logfile
                write(logfile, "$name nr$nr")
            end
        end
    end
end

