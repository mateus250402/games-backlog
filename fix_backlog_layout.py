with open("app/Pages/Backlog.hs", "r") as f:
    text = f.read()

# Replace the flexbox layout with Bootstrap grid
old_layout = '''                else div_ [class_ "d-flex flex-row flex-wrap align-items-start w-100", style_ ""] $
                        mapM_ (\\g -> div_ [class_ "game-card-container", style_ "flex: 1 1 31%; max-width: 31%; min-width: 300px; margin-right: 2%; margin-left: 0;"] $ gameCard g True) games'''

new_layout = '''                else div_ [class_ "row row-cols-1 row-cols-md-2 row-cols-lg-3 g-4"] $
                        mapM_ (\\g -> div_ [class_ "col"] $ gameCard g True) games'''

text = text.replace(old_layout, new_layout)

# Remove the old custom CSS for the container
old_css = '", "@media (max-width: 576px) { .game-card-container { flex: 1 1 100% !important; max-width: 100% !important; min-width: 100% !important; margin-right: 0 !important; margin-left: 0 !important; margin-bottom: 1rem !important; } }"'
text = text.replace(old_css, '')

with open("app/Pages/Backlog.hs", "w") as f:
    f.write(text)
