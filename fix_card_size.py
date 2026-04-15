with open("app/Components/GameCard.hs", "r") as f:
    text = f.read()

# Clean up and resize styles
old_styles = '''gameCardStyles :: Text
gameCardStyles = T.concat
    [ ".game-card { border-radius: 1.5rem 1.5rem 2.5rem 2.5rem; box-shadow: 0 4px 16px 0 rgba(31,38,135,0.10); border: 1px solid #e0e0e0; color: #222; overflow: hidden; position: relative; padding: 0; background: #fff; transition: box-shadow 0.2s; height: 140px; display: flex; }"
    , ".game-card:hover { box-shadow: 0 8px 32px 0 rgba(31,38,135,0.18); }"
    , ".game-cover { border-radius: 1.5rem 0 0 1.5rem; box-shadow: 0 2px 8px 0 rgba(0,0,0,0.06); background: #222; height: 140px; width: 120px; object-fit: cover; display: block; }"
    , ".game-title { font-size: 1.3rem; line-height: 1.3;  font-weight: bold; letter-spacing: 0.5px; }"
    , ".game-info { font-size: 1rem; line-height: 1.3; }"
    , ".game-col { padding: 0.8rem 1rem !important; display: flex; flex-direction: column; justify-content: center; height: 140px; }", ".card-text-container { gap: 0.5rem; }", ".game-title { margin-bottom: 0.25rem; }"
    , ".game-img-col { padding: 0 !important; display: flex; align-items: center; justify-content: flex-start; background: #f0f0f0; width: 120px; height: 140px; }"
    , ".platinum-tag { position: absolute; top: 0; right: 0; background: rgba(0, 0, 0, 0.05); color: #4a6fa5; padding: 2px 10px; font-size: 1.1rem; border-radius: 0 1.5rem 0 0.8rem; z-index: 20; font-weight: 800; border-left: 1px solid rgba(0,0,0,0.2); border-bottom: 1px solid rgba(0,0,0,0.2); filter: sepia(1) hue-rotate(180deg) brightness(1.1) contrast(1.2); }"
    ]'''

new_styles = '''gameCardStyles :: Text
gameCardStyles = T.concat
    [ ".game-card { border-radius: 1.5rem; box-shadow: 0 4px 16px 0 rgba(31,38,135,0.10); border: 1px solid #e0e0e0; color: #222; overflow: hidden; position: relative; padding: 0; background: #fff; transition: box-shadow 0.2s; height: 100%; display: flex; flex-direction: column; }"
    , ".game-card:hover { box-shadow: 0 8px 32px 0 rgba(31,38,135,0.18); }"
    , ".game-cover { border-radius: 1.5rem 1.5rem 0 0; box-shadow: 0 2px 8px 0 rgba(0,0,0,0.06); background: #222; height: 180px; width: 100%; object-fit: cover; display: block; }"
    , ".game-title { font-size: 1.2rem; line-height: 1.2; font-weight: bold; letter-spacing: 0.5px; margin-bottom: 0.25rem; }"
    , ".game-info { font-size: 0.9rem; line-height: 1.2; }"
    , ".game-col { padding: 1rem !important; display: flex; flex-direction: column; justify-content: center; flex-grow: 1; }"
    , ".game-img-col { padding: 0 !important; display: flex; align-items: center; justify-content: flex-start; background: #f0f0f0; width: 100%; height: 180px; }"
    , ".platinum-tag { position: absolute; top: 8px; right: 8px; background: rgba(0, 0, 0, 0.05); color: #4a6fa5; padding: 2px 10px; font-size: 1.1rem; border-radius: 0.8rem; z-index: 20; font-weight: 800; border: 1px solid rgba(0,0,0,0.2); filter: sepia(1) hue-rotate(180deg) brightness(1.1) contrast(1.2); }"
    ]'''

text = text.replace(old_styles, new_styles)

# Also update the HTML structure to be vertical
old_html = '''    in div_ ([ class_ "game-card mb-2 position-relative"
             , style_ cardStyle
             ] ++ onClickAttr) $ do
        if gPlatinumed
            then div_ [class_ "platinum-tag"] "🏆"
            else ""
        div_ [class_ "game-img-col"] $
            case gCoverUrl of
                Just url -> img_ [src_ url, class_ "game-cover", alt_ "Capa do jogo", style_ (if not gPlayed then "filter: sepia(0.2);" else "")]
                Nothing  -> div_ [class_ "bg-secondary text-white text-center rounded w-100", style_ "height:140px; display:flex; align-items:center; justify-content:center;"] "Sem capa disponível"
        div_ [class_ "game-col flex-grow-1 card-text-container"] $ do
            div_ [class_ "game-title"] $ toHtml gTitle
            if gScore > 0
                then div_ [class_ "game-info"] $ strong_ "Nota: " <> toHtml (show gScore)
                else ""'''

new_html = '''    in div_ ([ class_ "game-card position-relative"
             , style_ cardStyle
             ] ++ onClickAttr) $ do
        div_ [class_ "game-img-col"] $ do
            if gPlatinumed
                then div_ [class_ "platinum-tag"] "🏆"
                else ""
            case gCoverUrl of
                Just url -> img_ [src_ url, class_ "game-cover", alt_ "Capa do jogo", style_ (if not gPlayed then "filter: sepia(0.2);" else "")]
                Nothing  -> div_ [class_ "bg-secondary text-white text-center rounded-top w-100", style_ "height:180px; display:flex; align-items:center; justify-content:center;"] "Sem capa disponível"
        div_ [class_ "game-col"] $ do
            div_ [class_ "game-title"] $ toHtml gTitle
            if gScore > 0
                then div_ [class_ "game-info"] $ strong_ "Nota: " <> toHtml (show gScore)
                else ""'''

text = text.replace(old_html, new_html)

with open("app/Components/GameCard.hs", "w") as f:
    f.write(text)
