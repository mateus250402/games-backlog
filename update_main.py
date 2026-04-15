with open("app/Main.hs", "r") as f:
    text = f.read()

text = text.replace(
    'post "/recomend" $ Session.requireAuth $ do Hd.postRecomend',
    'post "/recomend" $ Session.requireAuth $ do Hd.postRecomend\n        post "/ignore-recomend" $ Session.requireAuth $ do Hd.postIgnoreRecomend'
)

with open("app/Main.hs", "w") as f:
    f.write(text)
