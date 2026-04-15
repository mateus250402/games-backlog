import re

with open("app/Api/Igdb.hs", "r") as f:
    text = f.read()

# Replace the weight logic
old_calc = '''    calculateMatchScore :: GameResult -> [(T.Text, Double)] -> [(T.Text, Double)] -> Double
    calculateMatchScore game genreWeights themeWeights =
        let safeEq a b = T.toLower (T.strip a) == T.toLower (T.strip b)
            -- Gêneros têm um peso maior pois definem mais a gameplay base
            gScore = sum [w | g <- grGenres game, (name, w) <- genreWeights, safeEq g name]
            -- Temas ajudam a compor a nota, mas com peso ligeiramente menor
            tScore = sum [w | t <- grThemes game, (name, w) <- themeWeights, safeEq t name]
        in (gScore * 2.0) + tScore'''

new_calc = '''    calculateMatchScore :: GameResult -> [(T.Text, Double)] -> [(T.Text, Double)] -> Double
    calculateMatchScore game genreWeights themeWeights =
        let safeEq a b = T.toLower (T.strip a) == T.toLower (T.strip b)
            gScore = sum [w | g <- grGenres game, (name, w) <- genreWeights, safeEq g name]
            tScore = sum [w | t <- grThemes game, (name, w) <- themeWeights, safeEq t name]
        in gScore + tScore'''

text = text.replace(old_calc, new_calc)

with open("app/Api/Igdb.hs", "w") as f:
    f.write(text)
