with open("app/Components/GameCard.hs", "r") as f:
    text = f.read()

# Force the gap to be removed entirely, remove Bootstrap gap classes
text = text.replace(
    'div_ [class_ "game-col flex-grow-1 gap-0 gap-sm-2"] $ do\n            div_ [class_ "game-title mb-0 mb-sm-1"] $ toHtml gTitle\n            if gScore > 0\n                then div_ [class_ "game-info mt-0 mt-sm-1"] $ strong_ "Nota: " <> toHtml (show gScore)',
    'div_ [class_ "game-col flex-grow-1 card-text-container"] $ do\n            div_ [class_ "game-title"] $ toHtml gTitle\n            if gScore > 0\n                then div_ [class_ "game-info"] $ strong_ "Nota: " <> toHtml (show gScore)'
)

# Update CSS for desktop
text = text.replace(
    '".game-col { padding: 0.8rem 1rem !important; display: flex; flex-direction: column; justify-content: center; height: 140px; }"',
    '".game-col { padding: 0.8rem 1rem !important; display: flex; flex-direction: column; justify-content: center; height: 140px; }", ".card-text-container { gap: 0.5rem; }", ".game-title { margin-bottom: 0.25rem; }"'
)

# Update Mobile CSS
mobile_old = '''    , "  .game-title { font-size: 1.15rem; line-height: 1; max-width: 240px; display: block; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; margin-bottom: -2px !important; padding-bottom: 0 !important; } "
    , "  .game-info { font-size: 0.9rem; line-height: 1; margin-top: -2px !important; padding-top: 0 !important; opacity: 0.9; } "'''

mobile_new = '''    , "  .card-text-container { gap: 0px !important; justify-content: center !important; } "
    , "  .game-title { font-size: 1.15rem; line-height: 1.2; max-width: 240px; display: block; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; margin-bottom: 0 !important; padding-bottom: 0 !important; } "
    , "  .game-info { font-size: 0.9rem; line-height: 1.2; margin-top: 0 !important; padding-top: 0 !important; opacity: 0.9; } "'''

text = text.replace(mobile_old, mobile_new)

with open("app/Components/GameCard.hs", "w") as f:
    f.write(text)
