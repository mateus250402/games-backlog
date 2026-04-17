{-# LANGUAGE OverloadedStrings #-}

module Pages.Backlog where

import Lucid
import Models.Games (Game(..))
import Data.Text (Text)
import qualified Data.Text as T
import Components.EditModal (editModal, editModalScripts)
import Components.GameCard (gameCard, gameCardStyles, gameCardMobileStyles)

backlogPage :: Text -> Text -> Text -> Bool -> Bool -> Bool -> [Game] -> Html ()
backlogPage searchFilter platformFilter sortFilter wantToPlayFilter playedFilter platinumedFilter games = html_ $ do
    head_ $ do
        title_ "Meu Backlog - Games Backlog"
        meta_ [charset_ "utf-8"]
        meta_ [name_ "viewport", content_ "width=device-width, initial-scale=1"]
        link_ [rel_ "stylesheet", href_ "https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"]
        script_ [src_ "https://unpkg.com/htmx.org@1.9.10"] ("" :: Text)
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
                    a_ [class_ "nav-link", href_ "/tournament"] "O que Jogar?"
        div_ [class_ "container-mobile mt-5"] $ do
            h1_ [class_ "mb-4 text-center text-dark fw-bold"] "Meu Backlog"

            div_ [class_ "mb-4 text-center d-flex justify-content-center gap-2 flex-wrap"] $ do
                a_ [href_ "/add", class_ "btn btn-success"] "Adicionar Jogo"
                a_ [href_ "/tournament", class_ "btn btn-warning fw-bold"] "🏆 O que Jogar?"
                a_ [href_ "/", class_ "btn btn-outline-primary"] "Home"

            form_ [ id_ "filter-form"
                  , method_ "get"
                  , action_ "/backlog"
                  , class_ "mb-4 d-flex flex-wrap justify-content-center align-items-center gap-2"
                  , data_ "hx-get" "/backlog"
                  , data_ "hx-target" "#game-list"
                  , data_ "hx-select" "#game-list"
                  , data_ "hx-trigger" "change from:select, change from:input[type='checkbox'], input from:#search-input delay:300ms"
                  , data_ "hx-push-url" "true"
                  , data_ "hx-indicator" "#loading-indicator"
                  , data_ "hx-swap" "innerHTML transition:true"
                  ] $ do
                input_ ([id_ "search-input", type_ "text", name_ "search", placeholder_ "Pesquisar jogos...", class_ "form-control", style_ "max-width: 250px;"] ++ if T.null searchFilter then [] else [value_ searchFilter])
                select_ [id_ "platform-select", name_ "platform", class_ "form-select w-auto"] $ do
                    option_ ([value_ ""] ++ if T.null platformFilter then [selected_ ""] else []) "Todas"
                    option_ ([value_ "PlayStation"] ++ if platformFilter == "PlayStation" then [selected_ ""] else []) "PlayStation"
                    option_ ([value_ "Nintendo"] ++ if platformFilter == "Nintendo" then [selected_ ""] else []) "Nintendo"
                    option_ ([value_ "PC"] ++ if platformFilter == "PC" then [selected_ ""] else []) "PC"
                    option_ ([value_ "Xbox"] ++ if platformFilter == "Xbox" then [selected_ ""] else []) "Xbox"
                select_ [id_ "sort-select", name_ "sort", class_ "form-select w-auto"] $ do
                    option_ ([value_ "alpha"] ++ if sortFilter == "alpha" then [selected_ ""] else []) "Ordem Alfabética"
                    option_ ([value_ "recent"] ++ if sortFilter == "recent" then [selected_ ""] else []) "Mais Recentes"
                    option_ ([value_ "score"] ++ if sortFilter == "score" then [selected_ ""] else []) "Ordenar por Nota"

                div_ [class_ "d-flex gap-3 px-2"] $ do
                    div_ [class_ "form-check"] $ do
                        input_ ([type_ "checkbox", name_ "want_to_play", class_ "form-check-input", id_ "filterWantToPlay"] ++ if wantToPlayFilter then [checked_] else [])
                        label_ [class_ "form-check-label", for_ "filterWantToPlay"] "Quero Jogar"
                    div_ [class_ "form-check"] $ do
                        input_ ([type_ "checkbox", name_ "played", class_ "form-check-input", id_ "filterPlayed"] ++ if playedFilter then [checked_] else [])
                        label_ [class_ "form-check-label", for_ "filterPlayed"] "Jogado"
                    div_ [class_ "form-check"] $ do
                        input_ ([type_ "checkbox", name_ "platinumed", class_ "form-check-input", id_ "filterPlatinumed"] ++ if platinumedFilter then [checked_] else [])
                        label_ [class_ "form-check-label", for_ "filterPlatinumed"] "Platinado"

            h2_ [class_ "mt-4 mb-3 text-secondary d-flex align-items-center gap-2"] $ do
                span_ "Jogos Salvos"
                div_ [id_ "loading-indicator", class_ "htmx-indicator spinner-border spinner-border-sm text-primary", role_ "status"] $
                    span_ [class_ "visually-hidden"] "Carregando..."

            div_ [id_ "game-list", class_ "fade-in"] $
                if null games
                    then p_ [class_ "text-center text-muted fs-4"] "Nenhum jogo salvo ainda."
                    else div_ [class_ "row row-cols-2 row-cols-sm-2 row-cols-md-4 row-cols-lg-5 row-cols-xl-6 g-2 g-sm-4"] $
                            mapM_ (\g -> div_ [class_ "col"] $ gameCard g True) games

customStyle :: Text
customStyle = T.concat
    [ "body { background: #f8f9fa; }"
    , ".htmx-indicator { display: none; }"
    , ".htmx-request .htmx-indicator { display: inline-block; }"
    , ".htmx-request#game-list { opacity: 0.5; transition: opacity 0.2s ease-in-out; }"
    , ".fade-in { animation: fadeIn 0.3s ease-in-out; }"
    , "@keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }"
    , gameCardStyles
    , ".delete-form { position: absolute; top: 8px; right: 8px; z-index: 10; margin: 0; }"
    , ".htmx-request.game-card { opacity: 0.5; }"
    , ".delete-btn { width: 28px; height: 28px; border-radius: 50%; padding: 0; display: flex; align-items: center; justify-content: center; font-size: 18px; font-weight: bold; line-height: 1; opacity: 0.6; transition: opacity 0.2s, transform 0.2s; background: transparent; border: none; color: #666; }"
    , ".delete-btn:hover { opacity: 1; transform: scale(1.1); color: #dc3545; }"
    , ".game-card:hover .delete-btn { opacity: 0.8; }"
    , ".container-mobile { width: 100%; padding-right: var(--bs-gutter-x, .75rem); padding-left: var(--bs-gutter-x, .75rem); margin-right: auto; margin-left: auto; } @media (min-width: 576px) { .container-mobile { max-width: 540px; } } @media (min-width: 768px) { .container-mobile { max-width: 720px; } } @media (min-width: 992px) { .container-mobile { max-width: 960px; } } @media (min-width: 1200px) { .container-mobile { max-width: 1140px; } } @media (min-width: 1400px) { .container-mobile { max-width: 1320px; } } @media (max-width: 576px) { .container-mobile { padding-left: 10px; padding-right: 10px; max-width: 100%; } .row { --bs-gutter-x: 0.5rem; } }"
    , "@media (max-width: 576px) { .btn { padding: 0.5rem 0.75rem; font-size: 0.9rem; } .form-control, .form-select { font-size: 16px; } }"
    , gameCardMobileStyles
    ]
