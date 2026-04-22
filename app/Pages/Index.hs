{-# LANGUAGE OverloadedStrings #-}

module Pages.Index where

import Data.Text (Text)
import Lucid

indexPage :: Maybe Text -> Html ()
indexPage maybeError = html_ [lang_ "pt-br"] $ do
    head_ $ do
        title_ "Games Backlog - Home"
        meta_ [charset_ "utf-8"]
        meta_ [name_ "viewport", content_ "width=device-width, initial-scale=1"]
        link_ [href_ "https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css", rel_ "stylesheet"]


    body_ $ do
        -- Navbar
        nav_ [class_ "navbar navbar-expand-lg navbar-dark bg-primary"] $ do
            div_ [class_ "container"] $ do
                a_ [class_ "navbar-brand", href_ "/"] "🎮 Games Backlog"
                div_ [class_ "navbar-nav ms-auto"] $ do
                    a_ [class_ "nav-link", href_ "/login"] "Login"
                    a_ [class_ "nav-link", href_ "/register"] "Registrar"
                    a_ [class_ "nav-link", href_ "/logout"] "Logout"

        -- Hero Section
        div_ [class_ "container mt-5"] $ do
            case maybeError of
                Just errorMessage ->
                    div_ [class_ "row justify-content-center mb-4"] $
                        div_ [class_ "col-md-10 col-lg-8"] $
                            div_ [class_ "alert alert-warning shadow-sm border-0 rounded-4 px-4 py-4"] $ do
                                h4_ [class_ "alert-heading fw-bold mb-3"] "Ops! Tivemos um problema por aqui."
                                p_ [class_ "mb-2"] "A tela nao carregou como esperado, mas voce pode tentar novamente sem sair do app."
                                p_ [class_ "mb-3 text-secondary"] (toHtml errorMessage)
                                div_ [class_ "d-flex flex-wrap gap-2"] $ do
                                    a_ [class_ "btn btn-warning fw-semibold", href_ "/"] "Tentar de novo"
                                    a_ [class_ "btn btn-outline-dark", href_ "/backlog"] "Ir para o backlog"
                Nothing -> mempty

            div_ [class_ "row justify-content-center"] $ do
                div_ [class_ "col-md-8 text-center"] $ do
                    h1_ [class_ "display-4 mb-4"] "Bem-vindo ao Games Backlog"
                    p_ [class_ "lead mb-4"] "Organize, avalie e gerencie seus jogos favoritos!"
                    div_ [class_ "d-grid gap-2 d-sm-flex justify-content-sm-center"] $ do
                        a_ [class_ "btn btn-primary btn-lg me-sm-2", href_ "/backlog"] "Meu Backlog"
                        a_ [class_ "btn btn-outline-primary btn-lg me-sm-2", href_ "/add"] "Adicionar Jogo"
                        a_ [class_ "btn btn-outline-primary btn-lg", href_ "/recomend"] "Gerar Recomendações"

        -- Features
        div_ [class_ "container mt-5"] $ do

            div_ [class_ "row"] $ do
                div_ [class_ "col-md-4 text-center mb-4"] $ do
                    div_ [class_ "card h-100"] $ do
                        div_ [class_ "card-body"] $ do
                            h5_ [class_ "card-title"] "📝 Organize"
                            p_ [class_ "card-text"] "Mantenha uma lista organizada dos seus jogos"

                div_ [class_ "col-md-4 text-center mb-4"] $ do
                    div_ [class_ "card h-100"] $ do
                        div_ [class_ "card-body"] $ do
                            h5_ [class_ "card-title"] "⭐ Avalie"
                            p_ [class_ "card-text"] "Dê notas aos jogos que você completou"

                div_ [class_ "col-md-4 text-center mb-4"] $ do
                    div_ [class_ "card h-100"] $ do
                        div_ [class_ "card-body"] $ do
                            h5_ [class_ "card-title"] "🎯 Acompanhe"
                            p_ [class_ "card-text"] "Veja seu progresso e estatísticas"


        script_ [src_ "https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"]  ("" :: Html ())
