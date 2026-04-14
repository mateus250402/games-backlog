{-# LANGUAGE OverloadedStrings #-}

module Pages.Confirm where

import Lucid
import Data.Text (Text)
import qualified Data.Text as T
import Models.Games (Game(..))
import Components.GameCard (gameCard, gameCardStyles, gameCardMobileStyles)

confirmPage :: Text -> Text -> Text -> Maybe Text -> Bool -> Bool -> Html ()
confirmPage name score platform maybeCover played platinumed = html_ $ do
    head_ $ do
        title_ "Confirmar Jogo - Games Backlog"
        meta_ [charset_ "utf-8"]
        link_ [rel_ "stylesheet", href_ "https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"]
        style_ customStyle
    body_ [] $ do
        nav_ [class_ "navbar navbar-expand-lg navbar-dark bg-primary"] $
            div_ [class_ "container"] $
                a_ [class_ "navbar-brand", href_ "/"] "🎮 Games Backlog"

        div_ [class_ "container mt-5"] $ do
            h1_ [class_ "mb-4 text-center text-dark"] "Confirmar Jogo"

            div_ [class_ "row justify-content-center"] $
                div_ [class_ "col-12 col-sm-10 col-md-8 col-lg-6"] $
                    -- Criamos um objeto Game temporário (id 0) para exibição no card
                    -- O segundo parâmetro 'False' indica que o card não deve ser clicável nesta página
                    gameCard (Game 0 name (if score == "" then 0 else read (T.unpack score)) platform maybeCover played platinumed) False

            div_ [class_ "row justify-content-center mt-4"] $
                div_ [class_ "col-lg-8 text-center"] $ do
                    form_ [method_ "post", action_ "/confirm", class_ "d-inline-block"] $ do
                        input_ [type_ "hidden", name_ "name", value_ name]
                        input_ [type_ "hidden", name_ "score", value_ score]
                        input_ [type_ "hidden", name_ "platform", value_ platform]
                        input_ [type_ "hidden", name_ "played", value_ (if played then "on" else "")]
                        input_ [type_ "hidden", name_ "platinumed", value_ (if platinumed then "on" else "")]
                        case maybeCover of
                            Just coverUrl -> input_ [type_ "hidden", name_ "cover_url", value_ coverUrl]
                            Nothing -> input_ [type_ "hidden", name_ "cover_url", value_ ""]
                        button_ [type_ "submit", class_ "btn btn-success btn-lg px-5"] "Confirmar e Salvar"

customStyle :: Text
customStyle = T.concat
    [ "body { background: #f8f9fa; }"
    , gameCardStyles
    , gameCardMobileStyles
    ]
