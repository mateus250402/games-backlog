with open("app/Components/GameCard.hs", "r") as f:
    text = f.read()

mobile_old = '''    , "  .game-title { font-size: 1.1rem; line-height: 1.1; max-width: 240px; display: block; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; margin-bottom: 0 !important; } "
    , "  .game-info { font-size: 0.85rem; line-height: 1.1; margin-top: 0 !important; } "'''

mobile_new = '''    , "  .game-title { font-size: 1.15rem; line-height: 1; max-width: 240px; display: block; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; margin-bottom: -2px !important; padding-bottom: 0 !important; } "
    , "  .game-info { font-size: 0.9rem; line-height: 1; margin-top: -2px !important; padding-top: 0 !important; opacity: 0.9; } "'''

text = text.replace(mobile_old, mobile_new)

with open("app/Components/GameCard.hs", "w") as f:
    f.write(text)
