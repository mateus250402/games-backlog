import re

with open("app/Api/Igdb.hs", "r") as f:
    text = f.read()

# 1. Restore rankedThemes
old_ranked = r'    let rankedThemes = take 5 \$ rankByPreference \(filter \(\\\(name, _, _\) -> T\.toLower \(T\.strip name\) /= "action"\) \(rcThemes criteria\)\)'
new_ranked = '    let rankedThemes = take 5 $ rankByPreference (rcThemes criteria)'
text = re.sub(old_ranked, new_ranked, text)

# 2. Fix calculateMatchScore (restore 1:1 weight)
old_score = '''    calculateMatchScore :: GameResult -> [(T.Text, Double)] -> [(T.Text, Double)] -> Double
    calculateMatchScore game genreWeights themeWeights =
        let safeEq a b = T.toLower (T.strip a) == T.toLower (T.strip b)
            gScore = sum [w | g <- grGenres game, (name, w) <- genreWeights, safeEq g name]
            tScore = sum [w | t <- grThemes game, (name, w) <- themeWeights, safeEq t name]
        in gScore + (tScore * 1.5)'''

new_score = '''    calculateMatchScore :: GameResult -> [(T.Text, Double)] -> [(T.Text, Double)] -> Double
    calculateMatchScore game genreWeights themeWeights =
        let safeEq a b = T.toLower (T.strip a) == T.toLower (T.strip b)
            gScore = sum [w | g <- grGenres game, (name, w) <- genreWeights, safeEq g name]
            tScore = sum [w | t <- grThemes game, (name, w) <- themeWeights, safeEq t name]
        in gScore + tScore'''

text = text.replace(old_score, new_score)

# 3. Penalize "Action" inside rankByPreference
old_rank = '''    rankByPreference :: [(T.Text, Int, Double)] -> [(T.Text, Double)]
    rankByPreference stats =
        let scored = map (\\(name, count, sumScore) ->
                let avg = if count > 0 then sumScore / fromIntegral count else 0
                    -- Balanceamento matemático:
                    -- Multiplicamos o volume por um fator fixo e usamos log para suavizar grandes discrepâncias
                    -- E somamos com a nota média, garantindo que ambos influenciem de forma equilibrada
                    volumeScore = logBase 2 (fromIntegral count + 1) * 3.0
                    weight = volumeScore + (avg * 1.2)
                in (name, weight)) stats
        in reverse $ sortOn snd scored'''

new_rank = '''    rankByPreference :: [(T.Text, Int, Double)] -> [(T.Text, Double)]
    rankByPreference stats =
        let scored = map (\\(name, count, sumScore) ->
                let avg = if count > 0 then sumScore / fromIntegral count else 0
                    volumeScore = logBase 2 (fromIntegral count + 1) * 3.0
                    baseWeight = volumeScore + (avg * 1.2)
                    -- Diminui significativamente o peso do tema "Action" (Ação) para não dominar as recomendações
                    weight = if T.toLower (T.strip name) == "action" then baseWeight * 0.3 else baseWeight
                in (name, weight)) stats
        in reverse $ sortOn snd scored'''

text = text.replace(old_rank, new_rank)

with open("app/Api/Igdb.hs", "w") as f:
    f.write(text)
