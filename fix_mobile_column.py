with open("app/Pages/Backlog.hs", "r") as f:
    text = f.read()

old_css = '"@media (max-width: 576px) { .game-card-container { flex: 1 1 100% !important; max-width: 100% !important; } }"'
new_css = '"@media (max-width: 576px) { .game-card-container { flex: 1 1 100% !important; max-width: 100% !important; min-width: 100% !important; margin-right: 0 !important; margin-left: 0 !important; margin-bottom: 1rem !important; } }"'

text = text.replace(old_css, new_css)

with open("app/Pages/Backlog.hs", "w") as f:
    f.write(text)
