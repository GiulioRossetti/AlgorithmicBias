include("utils.jl")

using LightGraphs
using StatsBase
using ProgressBars

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


function deffuant(g, ϵ, max_t; nsteady=10)
    res = []
    st = 0
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

        is_steady(new_opinions, old_opinions) ? st += 1 : st = 0

        ops = Tuple(new_opinions)
        append!(res,[ops])
        old_opinions = new_opinions

        if st == nsteady
            return res
        end
    end
    return res
end
