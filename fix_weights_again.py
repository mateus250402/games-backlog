import re

with open("app/Api/Igdb.hs", "r") as f:
    text = f.read()

old_calc = '''    calculateMatchScore :: GameResult -> [(T.Text, Double)] -> [(T.Text, Double)] -> Double
    calculateMatchScore game genreWeights themeWeights =
        let safeEq a b = T.toLower (T.strip a) == T.toLower (T.strip b)
            gScore = sum [w | g <- grGenres game, (name, w) <- genreWeights, safeEq g name]
            tScore = sum [w | t <- grThemes game, (name, w) <- themeWeights, safeEq t name]
        in gScore + tScore'''

new_calc = '''    calculateMatchScore :: GameResult -> [(T.Text, Double)] -> [(T.Text, Double)] -> Double
    calculateMatchScore game genreWeights themeWeights =
        let safeEq a b = T.toLower (T.strip a) == T.toLower (T.strip b)
            gScore = sum [w | g <- grGenres game, (name, w) <- genreWeights, safeEq g name]
            tScore = sum [w | t <- grThemes game, (name, w) <- themeWeights, safeEq t name]
        in gScore + (tScore * 1.5)'''

text = text.replace(old_calc, new_calc)

with open("app/Api/Igdb.hs", "w") as f:
    f.write(text)
