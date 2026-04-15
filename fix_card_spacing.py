with open("app/Components/GameCard.hs", "r") as f:
    text = f.read()

text = text.replace(
    'div_ [class_ "game-col flex-grow-1"] $ do\n            div_ [class_ "game-title mb-0"] $ toHtml gTitle\n            if gScore > 0\n                then div_ [class_ "game-info mb-0"] $ strong_ "Nota: " <> toHtml (show gScore)',
    'div_ [class_ "game-col flex-grow-1 gap-2"] $ do\n            div_ [class_ "game-title mb-1"] $ toHtml gTitle\n            if gScore > 0\n                then div_ [class_ "game-info mt-1"] $ strong_ "Nota: " <> toHtml (show gScore)'
)

text = text.replace(
    '".game-title { font-size: 1.25rem; line-height: 1.2;  font-weight: bold; letter-spacing: 0.5px; }"',
    '".game-title { font-size: 1.3rem; line-height: 1.3;  font-weight: bold; letter-spacing: 0.5px; }"'
)

text = text.replace(
    '".game-info { font-size: 0.95rem; line-height: 1.1; }"',
    '".game-info { font-size: 1rem; line-height: 1.3; }"'
)

with open("app/Components/GameCard.hs", "w") as f:
    f.write(text)
