using LightGraphs
using StatsBase
using ProgressBars
using CSV
using DataFrames
using Plots


function bias_media_iteration(g, ϵ, γ, γₘ, pₘ, media_op, old_opinions, new_opinions)

    for u in vertices(g)

        uₒ::Float16 = Float16(old_opinions[u])

        media_access = rand()
        o::Float16 = uₒ
        if media_access < pₘ
            # biased access to media
            media_within_bound = [abs(uₒ - x) <= ϵ for x in media_op]
            candidate_media = media_op[media_within_bound]
            # target media selection
            if size(candidate_media)[1] > 0
                mediaₚϵ = [abs(uₒ - x)^γ for x in candidate_media]
                mediaₚϵ /= sum(mediaₚϵ)
                selected = sample(candidate_media, Weights(mediaₚϵ))
                o = (selected + uₒ) / 2
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
            nn = Float16((old_opinions[selected] + o) / 2)
            new_opinions[u] = nn
        end
    end
    return new_opinions
end


function deffuant_bias_media(g, ϵ, γ, γₘ, pₘ, media_op, max_t)
    res = []
    # shared opinion arrays
    old_opinions = Array{Float16}(undef, nv(g))
    new_opinions = Array{Float16}(undef, nv(g))
    for u in vertices(g)
        op = rand()
        old_opinions[u] = Float16(op)
        new_opinions[u] = Float16(op)
    end

    media_op = [Float16(o) for o in media_op]

    for t in ProgressBar(1:max_t)
        new_opinions = bias_media_iteration(g, ϵ, γ, γₘ, pₘ, media_op, old_opinions, new_opinions)
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
    savefig(filename)
end

#########################################
max_t = 100
media_op = [0.1, 0.5, 0.9]

n = 250
p = 1.0
g = erdos_renyi(n, p)

for ϵ in [0.1, 0.2, 0.3, 0.4], γ in [0, 1, 1.5, 2], γₘ in  [0, 1, 1.5, 2],  pₘ in [0.1, 0.2, 0.3, 0.4]

    experiment_name = "Media_$n-$ϵ-$γ-$(γₘ)-$(pₘ)-$media_op-$max_t"

    # model call
    r =  deffuant_bias_media(g, ϵ, γ, γₘ, pₘ, media_op, max_t)
    println("Loading DataFrame")
    df = DataFrame(r)

    println("Saving results")
    CSV.write("res/$experiment_name.csv",  df, header=false)
    spaghetti_plot(df, max_t, "plots/$experiment_name.png")

end
