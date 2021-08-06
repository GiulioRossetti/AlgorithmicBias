using DataFrames
using Plots

function is_steady(a, b, toll=0.001)
    return all([x <= toll for x in abs.(a-b)])
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

function population_clusters(data, ϵ)
    sort!(data)
    start:: Float16 = data[1]
    max_val:: Float16 = start + ϵ
    c = (start::Float16, Float16(max_val))
    cluster = Dict()
    for i in data
        if i <= max_val
            if c in keys(cluster)
                push!(cluster, c => cluster[c]+1)
            else
                push!(cluster, c => 1)
            end
        else
            max_val = Float16(i + ϵ)
            c = (i::Float16, Float16(max_val))
            push!(cluster, c => 1)
        end
    end
    return cluster
end
