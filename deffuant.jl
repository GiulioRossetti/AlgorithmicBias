using LightGraphs
using StatsBase
using ProgressBars
using CSV
using DataFrames
using Plots
#using GR


function deffuant_iteration(g, ϵ, old_opinions, new_opinions)
    res = []
    for n in vertices(g)
        # get actual opinion of the node
        pₙ = old_opinions[n]
        # computing neighbors
        Γ = neighbors(g, n)
        # obtaining neighbors' opinions
        Γₚ = [old_opinions[x] for x in Γ]
        within_bound = [abs(pₙ - x) <= ϵ for x in Γₚ]
        likeminded = Γ[within_bound]
        # randomly select the target neighbor among the candidates
        if size(likeminded)[1] > 0
            selected = rand(likeminded)
            nn = abs(old_opinions[selected] + pₙ) / 2
            new_opinions[n] = nn
        end
    end
    return new_opinions
end


function deffuant(g, ϵ, max_t)
    res = []
    # shared opinion arrays
    old_opinions = Array{Float16}(undef, nv(g))
    new_opinions = Array{Float16}(undef, nv(g))
    for n in vertices(g)
        op = rand()
        old_opinions[n] = op
        new_opinions[n] = op
    end
    for t in ProgressBar(1:max_t)
        new_opinions = deffuant_iteration(g, ϵ, old_opinions, new_opinions)
        ops = Tuple(new_opinions)
        append!(res,[ops])
        old_opinions = new_opinions
    end
    return res
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

#########################################

max_t = 200
n = 250
p = 1.0
g = erdos_renyi(n, p)

for ϵ in [0.1, 0.2, 0.3, 0.4]

    experiment_name = "Deffuant_$n-$ϵ-$max_t"
    println(experiment_name)

    r = deffuant(g, ϵ, max_t)

    println("Loading DataFrame")
    df = DataFrame(r)

    println("Saving results")
    CSV.write("res/$experiment_name.csv",  df, header=false)
    spaghetti_plot(df, max_t, "plots/$experiment_name.png")

end
