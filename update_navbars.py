import re

# Update Pages.Backlog.hs
with open("app/Pages/Backlog.hs", "r") as f:
    content = f.read()

backlog_nav_replacement = """        nav_ [class_ "navbar navbar-expand-lg navbar-dark bg-primary"] $
            div_ [class_ "container"] $ do
                a_ [class_ "navbar-brand", href_ "/"] "🎮 Games Backlog"
                div_ [class_ "navbar-nav ms-auto"] $ do
                    a_ [class_ "nav-link", href_ "/recomend"] "Recomendações"
"""
content = re.sub(
    r'        nav_ \[class_ "navbar navbar-expand-lg navbar-dark bg-primary"\] \$\n            div_ \[class_ "container"\] \$\n                a_ \[class_ "navbar-brand", href_ "/"\] "🎮 Games Backlog"\n',
    backlog_nav_replacement,
    content
)

with open("app/Pages/Backlog.hs", "w") as f:
    f.write(content)

# Update Pages.Recomendation.hs
with open("app/Pages/Recomendation.hs", "r") as f:
    content = f.read()

recomend_nav_replacement = """        nav_ [class_ "navbar navbar-expand-lg navbar-dark bg-primary"] $
            div_ [class_ "container"] $ do
                a_ [class_ "navbar-brand", href_ "/"] "🎮 Games Backlog"
                div_ [class_ "navbar-nav ms-auto"] $ do
                    a_ [class_ "nav-link", href_ "/backlog"] "Backlog"
"""
content = re.sub(
    r'        nav_ \[class_ "navbar navbar-expand-lg navbar-dark bg-primary"\] \$\n            div_ \[class_ "container"\] \$\n                a_ \[class_ "navbar-brand", href_ "/"\] "🎮 Games Backlog"\n',
    recomend_nav_replacement,
    content
)

with open("app/Pages/Recomendation.hs", "w") as f:
    f.write(content)

