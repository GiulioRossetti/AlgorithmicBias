include("utils.jl")

using LightGraphs
using StatsBase
using ProgressBars


# function bias_iteration(g, ϵ, γ, old_opinions, new_opinions)

#     for n in vertices(g)
#         pₙ = old_opinions[n]
#         # computing neighbors
#         Γ = neighbors(g, n)
#         # obtaining neighbors' opinions
#         Γₚ = [old_opinions[x] for x in Γ]
#         # confidence bound filtering - by ϵ
#         within_bound = [abs(pₙ - x) <= ϵ for x in Γₚ]
#         likeminded = Γ[within_bound]

#         # target neighbor selection
#         if size(likeminded)[1] > 0
#             # biased sample by γ
#             Γₚϵ = [abs(pₙ - x)^γ for x in old_opinions[likeminded]]
#             Γₚϵ /= sum(Γₚϵ)
#             selected = sample(likeminded, Weights(Γₚϵ))
#             nn = (old_opinions[selected] + pₙ) / 2
#             new_opinions[n] = nn
#         end
#     end
#     return new_opinions
# end


function bias_iteration(g, ϵ, γ, old_opinions, new_opinions)
    new_opinions = copy(old_opinions)
    for u in vertices(g)
        # computing neighbors
        Γ = neighbors(g, u)
        # obtaining neighbors' opinions
        Γₚ = [new_opinions[x] for x in Γ] #cambiato
        Γₚϵ = [abs(new_opinions[u] - x)^(-γ) for x in new_opinions[Γ]] #cambiato
        Γₚϵ /= sum(Γₚϵ)
        selected = sample(Γ, Weights(Γₚϵ))
        # confidence bound filtering - by ϵ
        if abs(new_opinions[u] - new_opinions[selected]) < ϵ  
            nn = Float16((new_opinions[selected] + new_opinions[u]) / 2)
            new_opinions[u] = nn
            new_opinions[selected] = nn
        end
    end
    return new_opinions
end


function deffuant_bias(g, ϵ, γ, max_t; nsteady=1000)
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
        new_opinions = bias_iteration(g, ϵ, γ, old_opinions, new_opinions)

        is_steady(new_opinions, old_opinions) ? st += 1 : st = 0

        ops = Tuple(new_opinions)
        append!(res,[ops])
        old_opinions = copy(new_opinions)

        if st == nsteady
            return res[1:end-nsteady]
        end
    end
    return res
end
