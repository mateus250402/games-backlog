import re

with open("app/Pages/Recomendation.hs", "r") as f:
    text = f.read()

new_card = '''        div_ [class_ "card h-100 shadow-sm border-0 rounded-4 overflow-hidden position-relative"] $ do
            form_ [ method_ "post"
                  , action_ "/ignore-recomend"
                  , class_ "position-absolute"
                  , style_ "top: 8px; right: 8px; z-index: 10;"
                  ] $ do
                input_ [type_ "hidden", name_ "title", value_ title]
                button_ [ type_ "submit"
                        , class_ "btn btn-sm btn-light rounded-circle shadow-sm"
                        , style_ "width: 28px; height: 28px; padding: 0; display: flex; align-items: center; justify-content: center; font-size: 14px; opacity: 0.8;"
                        , title_ "Não recomendar este jogo"
                        ] "✖"
                        
            div_ [class_ "d-flex", style_ "height: 160px;"] $ do'''

text = text.replace(
    '''        div_ [class_ "card h-100 shadow-sm border-0 rounded-4 overflow-hidden position-relative"] $ do
            div_ [class_ "d-flex", style_ "height: 160px;"] $ do''',
    new_card
)

with open("app/Pages/Recomendation.hs", "w") as f:
    f.write(text)
