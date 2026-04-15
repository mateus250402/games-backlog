{-# LANGUAGE OverloadedStrings #-}

module Pages.AddGame where

import Lucid
import qualified Data.Text as T

addGamePage :: Maybe T.Text -> Maybe T.Text -> Html ()
addGamePage maybeName maybeSource = html_ $ do
    head_ $ do
        title_ "Adicionar Jogo - Games Backlog"
        meta_ [charset_ "utf-8"]
        link_ [ rel_ "stylesheet" , href_ "https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"]


    nav_ [class_ "navbar navbar-expand-lg navbar-dark bg-primary"] $ do
            div_ [class_ "container"] $ do
                a_ [class_ "navbar-brand", href_ "/"] "🎮 Games Backlog"
                div_ [class_ "navbar-nav ms-auto"] $ do
                    a_ [class_ "nav-link", href_ "/"] "Início"
                    a_ [class_ "nav-link", href_ "/backlog"] "Backlog"
                    a_ [class_ "nav-link", href_ "/logout"] "Logout"


    body_ [class_ "bg-light"] $ do
        div_ [class_ "container mt-5"] $ do
            h1_ [class_ "mb-4"] "Adicionar Jogo"
            form_ [method_ "post", action_ "/add", class_ "card p-4 shadow-sm"] $ do
                case maybeSource of
                    Just src -> input_ [type_ "hidden", name_ "source", value_ src]
                    Nothing -> return ()
                div_ [class_ "mb-3"] $ do
                    label_ [class_ "form-label"] "Nome do Jogo: "
                    input_ [type_ "text", name_ "name", required_ "", class_ "form-control", value_ (maybe "" id maybeName)]
                div_ [class_ "mb-3", id_ "score-container"] $ do
                    label_ [class_ "form-label"] "Nota (0-10): "
                    input_ [type_ "number", name_ "score", id_ "score-input", min_ "0", max_ "10", step_ "0.1", class_ "form-control", placeholder_ "Sem nota"]
                div_ [class_ "mb-3"] $ do
                    label_ [class_ "form-label"] "Plataforma: "
                    select_ [name_ "platform", required_ "", class_ "form-select"] $ do
                        option_ [value_ "PC"] "PC"
                        option_ [value_ "PlayStation"] "PlayStation"
                        option_ [value_ "Xbox"] "Xbox"
                        option_ [value_ "Nintendo"] "Nintendo"
                div_ [class_ "mb-3 d-flex gap-4"] $ do
                    div_ [class_ "form-check"] $ do
                        input_ [type_ "checkbox", name_ "want_to_play", class_ "form-check-input", id_ "wantToPlayCheck", onclick_ "toggleScore()"]
                        label_ [class_ "form-check-label", for_ "wantToPlayCheck"] "Quero jogar"
                    div_ [class_ "form-check"] $ do
                        input_ [type_ "checkbox", name_ "platinumed", class_ "form-check-input", id_ "platinumCheck"]
                        label_ [class_ "form-check-label", for_ "platinumCheck"] "Platinado"
                button_ [type_ "submit", class_ "btn btn-primary"] "Adicionar"
            p_ [class_ "mt-3"] $ a_ [href_ "/backlog", class_ "btn btn-link"] "Voltar ao Backlog"

        script_ $ T.unlines
            [ "function toggleScore() {"
            , "  const wantToPlay = document.getElementById('wantToPlayCheck').checked;"
            , "  const scoreInput = document.getElementById('score-input');"
            , "  const scoreContainer = document.getElementById('score-container');"
            , "  const platinumCheck = document.getElementById('platinumCheck');"
            , "  if (wantToPlay) {"
            , "    scoreInput.value = '';"
            , "    scoreInput.disabled = true;"
            , "    scoreContainer.style.opacity = '0.5';"
            , "    platinumCheck.checked = false;"
            , "    platinumCheck.disabled = true;"
            , "  } else {"
            , "    scoreInput.disabled = false;"
            , "    scoreContainer.style.opacity = '1';"
            , "    platinumCheck.disabled = false;"
            , "  }"
            , "}"
            , "window.onload = toggleScore;"
            ]
