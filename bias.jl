using LightGraphs
using StatsBase
using ProgressBars
using CSV
using DataFrames
using Plots
using GR


function bias_iteration(g, ϵ, γ, old_opinions, new_opinions)

    for n in vertices(g)
        pₙ = old_opinions[n]
        # computing neighbors
        Γ = neighbors(g, n)
        # obtaining neighbors' opinions
        Γₚ = [old_opinions[x] for x in Γ]
        # confidence bound filtering - by ϵ
        within_bound = [abs(pₙ - x) <= ϵ for x in Γₚ]
        likeminded = Γ[within_bound]

        # target neighbor selection
        if size(likeminded)[1] > 0
            # biased sample by γ
            Γₚϵ = [abs(pₙ - x)^γ for x in old_opinions[likeminded]]
            Γₚϵ /= sum(Γₚϵ)
            selected = sample(likeminded, Weights(Γₚϵ))
            nn = (old_opinions[selected] + pₙ) / 2
            new_opinions[n] = nn
        end
    end
    return new_opinions
end


function deffuant_bias(g, ϵ, γ, max_t)
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
        new_opinions = bias_iteration(g, ϵ, γ, old_opinions, new_opinions)
        ops = Tuple(new_opinions)
        append!(res,[ops])
        old_opinions = new_opinions
    end
    return res
end

function spaghetti_plot(df, max_t, filename)
    p = plot(1:max_t, df[!, 1], legend = false, color="#ffffff", ylims = (0,1))
    for i in 1:n
        if df[!, i][1] <= 0.33
            plot!(p, 1:max_t, df[!, i], color="#ff0000")
        elseif 0.33 < df[!, i][1] <= 0.66
            plot!(p, 1:max_t, df[!, i], color="#00ff00")
        else
            plot!(p, 1:max_t, df[!, i], color="#0000ff")
        end
    end
    Plots.savefig(filename)
end

#########################################
max_t = 10000
ϵ = 0.25
γ = 1.8
n = 100
p = 1.0
g = erdos_renyi(n, p)

experiment_name = "Bias_$n-$ϵ-$γ-$max_t"

# model call
r = deffuant_bias(g, ϵ, γ, max_t)
df = DataFrame(r)

CSV.write("$experiment_name.csv",  df, writeheader=false)
spaghetti_plot(df, max_t, "$experiment_name.pdf")
