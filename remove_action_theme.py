import re

with open("app/Api/Igdb.hs", "r") as f:
    text = f.read()

# Replace rankedThemes line
old_ranked = '    let rankedThemes = take 5 $ rankByPreference (rcThemes criteria)'
new_ranked = '    let rankedThemes = take 5 $ rankByPreference (filter (\(name, _, _) -> T.toLower (T.strip name) /= "action") (rcThemes criteria))'

text = text.replace(old_ranked, new_ranked)

with open("app/Api/Igdb.hs", "w") as f:
    f.write(text)
