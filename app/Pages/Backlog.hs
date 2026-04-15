{-# LANGUAGE OverloadedStrings #-}

module Pages.Backlog where

import Lucid
import Models.Games (Game(..))
import Data.Text (Text)
import qualified Data.Text as T
import Components.EditModal (editModal, editModalScripts)
import Components.GameCard (gameCard, gameCardStyles, gameCardMobileStyles)

backlogPage :: Text -> Text -> Text -> Bool -> Bool -> [Game] -> Html ()
backlogPage searchFilter platformFilter sortFilter wantToPlayFilter platinumedFilter games = html_ $ do
    head_ $ do
        title_ "Meu Backlog - Games Backlog"
        meta_ [charset_ "utf-8"]
        link_ [rel_ "stylesheet", href_ "https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"]
        style_ customStyle
    body_ [] $ do
        editModal

        script_ [src_ "https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"] ("" :: Text)
        editModalScripts

        nav_ [class_ "navbar navbar-expand-lg navbar-dark bg-primary"] $
            div_ [class_ "container"] $ do
                a_ [class_ "navbar-brand", href_ "/"] "🎮 Games Backlog"
                div_ [class_ "navbar-nav ms-auto"] $ do
                    a_ [class_ "nav-link", href_ "/recomend"] "Recomendações"
        div_ [class_ "container-mobile mt-5"] $ do
            h1_ [class_ "mb-4 text-center text-dark fw-bold"] "Meu Backlog"

            div_ [class_ "mb-4 text-center"] $ do
                a_ [href_ "/add", class_ "btn btn-success me-2"] "Adicionar Jogo"
                a_ [href_ "/", class_ "btn btn-outline-primary"] "Home"

            form_ [method_ "get", action_ "/backlog", class_ "mb-4 d-flex flex-wrap justify-content-center align-items-center gap-2"] $ do
                input_ ([type_ "text", name_ "search", placeholder_ "Pesquisar jogos...", class_ "form-control", style_ "max-width: 250px;"] ++ if T.null searchFilter then [] else [value_ searchFilter])
                select_ [name_ "platform", class_ "form-select w-auto"] $ do
                    option_ ([value_ ""] ++ if T.null platformFilter then [selected_ ""] else []) "Todas"
                    option_ ([value_ "PlayStation"] ++ if platformFilter == "PlayStation" then [selected_ ""] else []) "PlayStation"
                    option_ ([value_ "Nintendo"] ++ if platformFilter == "Nintendo" then [selected_ ""] else []) "Nintendo"
                    option_ ([value_ "PC"] ++ if platformFilter == "PC" then [selected_ ""] else []) "PC"
                    option_ ([value_ "Xbox"] ++ if platformFilter == "Xbox" then [selected_ ""] else []) "Xbox"
                select_ [name_ "sort", class_ "form-select w-auto"] $ do
                    option_ ([value_ "alpha"] ++ if sortFilter == "alpha" then [selected_ ""] else []) "Ordem Alfabética"
                    option_ ([value_ "recent"] ++ if sortFilter == "recent" then [selected_ ""] else []) "Mais Recentes"
                    option_ ([value_ "score"] ++ if sortFilter == "score" then [selected_ ""] else []) "Ordenar por Nota"

                div_ [class_ "d-flex gap-3 px-2"] $ do
                    div_ [class_ "form-check"] $ do
                        input_ ([type_ "checkbox", name_ "want_to_play", class_ "form-check-input", id_ "filterWantToPlay"] ++ if wantToPlayFilter then [checked_] else [])
                        label_ [class_ "form-check-label", for_ "filterWantToPlay"] "Quero Jogar"
                    div_ [class_ "form-check"] $ do
                        input_ ([type_ "checkbox", name_ "platinumed", class_ "form-check-input", id_ "filterPlatinumed"] ++ if platinumedFilter then [checked_] else [])
                        label_ [class_ "form-check-label", for_ "filterPlatinumed"] "Platinado"

                button_ [type_ "submit", class_ "btn btn-primary"] "Filtrar"

            h2_ [class_ "mt-4 mb-3 text-secondary"] "Jogos Salvos"
            if null games
                then p_ [class_ "text-center text-muted fs-4"] "Nenhum jogo salvo ainda."
                else div_ [class_ "row row-cols-1 row-cols-sm-2 row-cols-md-4 row-cols-lg-5 row-cols-xl-6 g-4"] $
                        mapM_ (\g -> div_ [class_ "col"] $ gameCard g True) games

customStyle :: Text
customStyle = T.concat
    [ "body { background: #f8f9fa; }"
    , gameCardStyles
    , ".delete-form { position: absolute; top: 8px; right: 8px; z-index: 10; margin: 0; }"
    , ".delete-btn { width: 28px; height: 28px; border-radius: 50%; padding: 0; display: flex; align-items: center; justify-content: center; font-size: 18px; font-weight: bold; line-height: 1; opacity: 0.6; transition: opacity 0.2s, transform 0.2s; background: transparent; border: none; color: #666; }"
    , ".delete-btn:hover { opacity: 1; transform: scale(1.1); color: #dc3545; }"
    , ".game-card:hover .delete-btn { opacity: 0.8; }"
    , ".container-mobile { width: 100%; padding-right: var(--bs-gutter-x, .75rem); padding-left: var(--bs-gutter-x, .75rem); margin-right: auto; margin-left: auto; } @media (min-width: 576px) { .container-mobile { max-width: 540px; } } @media (min-width: 768px) { .container-mobile { max-width: 720px; } } @media (min-width: 992px) { .container-mobile { max-width: 960px; } } @media (min-width: 1200px) { .container-mobile { max-width: 1140px; } } @media (min-width: 1400px) { .container-mobile { max-width: 1320px; } } @media (max-width: 576px) { .container-mobile { padding-left: 5px; padding-right: 5px; max-width: 100%; } }"
    , "@media (max-width: 576px) { .game-card-container { flex: 1 1 100% !important; max-width: 100% !important; min-width: 100% !important; margin-right: 0 !important; margin-left: 0 !important; margin-bottom: 1rem !important; } }"
    , gameCardMobileStyles
    ]
