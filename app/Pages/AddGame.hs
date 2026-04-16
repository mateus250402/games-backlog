{-# LANGUAGE OverloadedStrings #-}

module Pages.AddGame where

import Lucid
import qualified Data.Text as T

addGamePage :: Maybe T.Text -> Maybe T.Text -> Html ()
addGamePage maybeName maybeSource = html_ $ do
    head_ $ do
        title_ "Adicionar Jogo - Games Backlog"
        meta_ [charset_ "utf-8"]
        meta_ [name_ "viewport", content_ "width=device-width, initial-scale=1"]
        link_ [ rel_ "stylesheet" , href_ "https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"]
        style_ ".modal-open { overflow: hidden; } .custom-backdrop { background-color: rgba(0,0,0,0.6); position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; z-index: 1040; display: flex; align-items: center; justify-content: center; }"

    body_ [class_ "bg-light modal-open"] $ do
        nav_ [class_ "navbar navbar-expand-lg navbar-dark bg-primary"] $ do
            div_ [class_ "container"] $ do
                a_ [class_ "navbar-brand", href_ "/"] "🎮 Games Backlog"
                div_ [class_ "navbar-nav ms-auto"] $ do
                    a_ [class_ "nav-link", href_ "/"] "Início"
                    a_ [class_ "nav-link", href_ "/backlog"] "Backlog"
                    a_ [class_ "nav-link", href_ "/logout"] "Logout"

        -- Modal em formato de pop-up
        div_ [class_ "custom-backdrop"] $ do
            div_ [class_ "modal-dialog modal-dialog-centered shadow-lg", style_ "width: 100%; max-width: 500px; padding: 15px;"] $ do
                div_ [class_ "modal-content bg-white rounded-3 overflow-hidden w-100"] $ do
                    div_ [class_ "modal-header bg-primary text-white p-3 d-flex justify-content-between align-items-center"] $ do
                        h5_ [class_ "modal-title m-0 fw-bold"] "Adicionar Jogo"
                        a_ [href_ "/backlog", class_ "btn-close btn-close-white"] ""

                    div_ [class_ "modal-body p-4"] $ do
                        form_ [method_ "get", action_ "/game-selection"] $ do
                            case maybeSource of
                                Just src -> input_ [type_ "hidden", name_ "source", value_ src]
                                Nothing -> return ()

                            -- Passando valores padrão para compatibilidade com o backend
                            input_ [type_ "hidden", name_ "score", value_ ""]
                            input_ [type_ "hidden", name_ "platform", value_ "PC"]

                            div_ [class_ "mb-4"] $ do
                                label_ [class_ "form-label fw-bold"] "Pesquisar Jogo: "
                                input_ [type_ "text", name_ "name", required_ "", class_ "form-control", value_ (maybe "" id maybeName), autofocus_]

                            div_ [class_ "d-grid gap-2"] $ do
                                button_ [type_ "submit", class_ "btn btn-primary btn-lg fw-bold"] "Pesquisar"
                                a_ [href_ "/backlog", class_ "btn btn-outline-secondary"] "Cancelar"
