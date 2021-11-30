using CSV
using DataFrames
using JSON
using LightGraphs
using Statistics

function read_json(file)
    open(file,"r") do f
        global inDict
        inDict = JSON.parse(f)
    end
    return inDict
end