with open("app/Components/GameCard.hs", "r") as f:
    text = f.read()

# Update HTML classes to be responsive
text = text.replace('class_ "game-col flex-grow-1 gap-2"', 'class_ "game-col flex-grow-1 gap-0 gap-sm-2"')
text = text.replace('class_ "game-title mb-1"', 'class_ "game-title mb-0 mb-sm-1"')
text = text.replace('class_ "game-info mt-1"', 'class_ "game-info mt-0 mt-sm-1"')

# Update Mobile CSS
mobile_old = '''    , "  .game-title { font-size: 1.1rem; max-width: 240px; display: block; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; } "
    , "  .game-info { font-size: 0.85rem; } "'''

mobile_new = '''    , "  .game-title { font-size: 1.1rem; line-height: 1.1; max-width: 240px; display: block; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; margin-bottom: 0 !important; } "
    , "  .game-info { font-size: 0.85rem; line-height: 1.1; margin-top: 0 !important; } "'''

text = text.replace(mobile_old, mobile_new)

with open("app/Components/GameCard.hs", "w") as f:
    f.write(text)
