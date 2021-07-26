using LightGraphs
using StatsBase
using ProgressBars


function bias_media_iteration(g, ϵ, γ, γₘ, pₘ, media_op, old_opinions, new_opinions)

    for u in vertices(g)

        uₒ = old_opinions[u]

        media_access = rand()
        o = uₒ
        if media_access < pₘ
            # biased access to media
            media_within_bound = [abs(uₒ - x) <= ϵ for x in media_op]
            candidate_media = media_op[media_within_bound]
            # target media selection
            if size(candidate_media)[1] > 0
                mediaₚϵ = [abs(uₒ - x)^γ for x in candidate_media]
                mediaₚϵ /= sum(mediaₚϵ)
                selected = sample(candidate_media, Weights(mediaₚϵ))
                o = Float16((selected + uₒ) / 2)
            end
        end

        # computing neighbors
        Γ = neighbors(g, u)
        # obtaining neighbors' opinions
        Γₚ = [old_opinions[x] for x in Γ]
        # confidence bound filtering - by ϵ
        within_bound = [abs(uₒ - x) <= ϵ for x in Γₚ]
        likeminded = Γ[within_bound]

        # target neighbor selection
        if size(likeminded)[1] > 0
            # biased sample by γ
            Γₚϵ = [abs(uₒ - x)^γ for x in old_opinions[likeminded]]
            Γₚϵ /= sum(Γₚϵ)
            selected = sample(likeminded, Weights(Γₚϵ))
            nn = (old_opinions[selected] + o) / 2
            new_opinions[u] = nn
        end
    end
    return new_opinions
end


function deffuant_bias_media(g, ϵ, γ, γₘ, pₘ, media_op, max_t)
    res =[]
    # shared opinion arrays
    old_opinions = Array{Float16}(undef, nv(g))
    new_opinions = Array{Float16}(undef, nv(g))
    for u in vertices(g)
        op = rand()
        old_opinions[u] = op
        new_opinions[u] = op
    end

    obs = Tuple(old_opinions)
    append!(res,[obs])
    for t in ProgressBar(1:max_t)
        new_opinions = bias_media_iteration(g, ϵ, γ, γₘ, pₘ, media_op, old_opinions, new_opinions)
        ops = Tuple(new_opinions)
        append!(res,[ops])
        old_opinions = new_opinions
    end
end


#########################################
max_t = 1000000
ϵ = 0.35
γ = 1.8
γₘ = 1.0
pₘ = 0.3
media_op = [0.1, 0.5, 0.9]

n = 100
p = 1.0
g = erdos_renyi(n, p)


# model call
r = deffuant_bias_media(g, ϵ, γ, γₘ, pₘ, media_op, max_t)
