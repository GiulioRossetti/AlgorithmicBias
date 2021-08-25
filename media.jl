include("utils.jl")

using LightGraphs
using StatsBase
using ProgressBars



function bias_media_iteration(g, ϵ, γ, γₘ, pₘ, media_op, old_opinions, new_opinions)
    new_opinions = copy(old_opinions)
    for u in vertices(g)

        uₒ::Float16 = Float16(new_opinions[u]) #cambiato

        media_access = rand()
        o::Float16 = uₒ
        if media_access < pₘ
            # biased access to media
            media_within_bound = [abs(uₒ - x) <= ϵ for x in media_op]
            candidate_media = media_op[media_within_bound]
            # target media selection
            if size(candidate_media)[1] > 0
                mediaₚϵ = [abs(uₒ - x)^(-γ) for x in candidate_media] #cambiato segno esponente
                mediaₚϵ /= sum(mediaₚϵ)
                selected = sample(candidate_media, Weights(mediaₚϵ))
                o = (selected + uₒ) / 2
            end
        end

        # computing neighbors
        Γ = neighbors(g, u)
        # obtaining neighbors' opinions
        Γₚ = [new_opinions[x] for x in Γ] #cambiato
        # confidence bound filtering - by ϵ
        # within_bound = [abs(uₒ - x) <= ϵ for x in Γₚ] #però se io mi sono già spostato x interazione con media non va bene devo già considerare o nel calcolo dei neighbors within_bound
        within_bound = [abs(o - x) <= ϵ for x in Γₚ]        
        likeminded = Γ[within_bound]

        # target neighbor selection
        if size(likeminded)[1] > 0
            # biased sample by γ
            # Γₚϵ = [abs(uₒ - x)^γ for x in old_opinions[likeminded]] #anche qua devo già considerare o dopo interazione con media
            Γₚϵ = [abs(o - x)^(-γ) for x in new_opinions[likeminded]] #cambiato
            Γₚϵ /= sum(Γₚϵ)
            selected = sample(likeminded, Weights(Γₚϵ))
            nn = Float16((new_opinions[selected] + o) / 2)
            new_opinions[u] = new_opinions[selected] = nn
        end
    end
    return new_opinions
end


function deffuant_bias_media(g, ϵ, γ, γₘ, pₘ, media_op, max_t ; nsteady=1000)
    res = []
    st = 0
    # shared opinion arrays
    old_opinions = Array{Float16}(undef, nv(g))
    new_opinions = Array{Float16}(undef, nv(g))
    for u in vertices(g)
        op = rand()
        old_opinions[u] = Float16(op)
        new_opinions[u] = Float16(op)
    end

    media_op = [Float16(o) for o in media_op]
    st = 0
    for t in ProgressBar(1:max_t)
        new_opinions = bias_media_iteration(g, ϵ, γ, γₘ, pₘ, media_op, old_opinions, new_opinions)

        is_steady(new_opinions, old_opinions) ? st += 1 : st = 0

        ops = Tuple(new_opinions)
        append!(res,[ops])
        old_opinions = new_opinions

        if st == nsteady
            return res[1:end-nsteady]
        end

    end
    return res
end
