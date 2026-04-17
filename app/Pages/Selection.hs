{-# LANGUAGE OverloadedStrings #-}

module Pages.Selection where

import Lucid
import Data.Text (Text)
import qualified Data.Text as T
import Api.Igdb (GameResult(..))
import qualified Pages.AddGame as AddGame

gameSelectionPage :: Text -> Text -> Text -> Bool -> Bool -> Maybe Text -> [GameResult] -> Html ()
gameSelectionPage originalName _ _ _ _ maybeSource gameResults = html_ $ do
    head_ $ do
        title_ "Selecionar Jogo - Games Backlog"
        meta_ [charset_ "utf-8"]
        meta_ [name_ "viewport", content_ "width=device-width, initial-scale=1"]
        link_ [rel_ "stylesheet", href_ "https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"]
        script_ [src_ "https://unpkg.com/htmx.org@1.9.10"] ("" :: Text)
        style_ AddGame.customStyle

    body_ [class_ "bg-light"] $ do
        script_ AddGame.modalScripts
        nav_ [class_ "navbar navbar-expand-lg navbar-dark bg-primary"] $
            div_ [class_ "container"] $ do
                a_ [class_ "navbar-brand", href_ "/"] "🎮 Games Backlog"
                div_ [class_ "navbar-nav ms-auto"] $ do
                    a_ [class_ "nav-link", href_ "/"] "Início"
                    a_ [class_ "nav-link", href_ "/backlog"] "Backlog"

        div_ [class_ "container mt-5"] $ do
            div_ [class_ "row justify-content-center"] $ do
                div_ [class_ "col-md-10"] $ do
                    div_ [class_ "card shadow-sm border-0 rounded-4 overflow-hidden mb-5"] $ do
                        div_ [class_ "card-header bg-primary text-white p-4 text-center"] $ do
                            h3_ [class_ "m-0 fw-bold"] "Adicionar Novo Jogo"

                        div_ [class_ "card-body p-4"] $ do
                            form_ [ method_ "get"
                                  , action_ "/game-selection"
                                  , onsubmit_ "return false;"
                                  , data_ "hx-get" "/game-selection"
                                  , data_ "hx-target" "#search-results"
                                  , data_ "hx-select" "#search-results"
                                  , data_ "hx-trigger" "input from:#search-name delay:300ms, keyup[key=='Enter'] from:#search-name"
                                  , data_ "hx-push-url" "true"
                                  , data_ "hx-indicator" "#search-loading"
                                  , data_ "hx-swap" "innerHTML transition:true"
                                  ] $ do
                                case maybeSource of
                                    Just src -> input_ [type_ "hidden", name_ "source", value_ src]
                                    Nothing -> return ()

                                input_ [type_ "hidden", name_ "score", value_ ""]
                                input_ [type_ "hidden", name_ "platform", value_ "PC"]

                                div_ [class_ "mb-4"] $ do
                                    label_ [class_ "form-label fw-bold text-secondary"] "Digite o nome do jogo:"
                                    div_ [class_ "input-group input-group-lg"] $ do
                                        input_ [ id_ "search-name"
                                               , type_ "text"
                                               , name_ "name"
                                               , required_ ""
                                               , class_ "form-control"
                                               , placeholder_ "Ex: The Last of Us, Mario..."
                                               , value_ originalName
                                               , autofocus_
                                               ]
                                        div_ [id_ "search-loading", class_ "htmx-indicator input-group-text bg-white"] $
                                            div_ [class_ "spinner-border spinner-border-sm text-primary", role_ "status"] ""

                            div_ [id_ "search-results", class_ "mt-4 fade-in"] $ do
                                p_ [class_ "text-center text-muted mb-4 fw-bold"] $
                                    "Resultados para \"" <> toHtml originalName <> "\":"

                                div_ [class_ "row row-cols-1 row-cols-md-2 row-cols-lg-3 g-4"] $
                                    mapM_ (gameSelectionCard maybeSource) gameResults

                                -- OOB Swap para atualizar os campos ocultos do modal que dependem do nome original da pesquisa
                                div_ [id_ "gameModal-update", data_ "hx-swap-oob" "true"] $
                                    div_ [id_ "gameModal", class_ "custom-backdrop d-none"] (AddGame.modalContent originalName maybeSource)

                            div_ [class_ "text-center mt-4"] $
                                a_ [href_ "/backlog", class_ "btn btn-link text-decoration-none text-muted"] "Voltar ao Backlog"

        -- Modal HTML (carregamento inicial)
        div_ [id_ "gameModal-update"] $ do
            div_ [id_ "gameModal", class_ "custom-backdrop d-none"] (AddGame.modalContent originalName maybeSource)

gameSelectionCard :: Maybe Text -> GameResult -> Html ()
gameSelectionCard _ (GameResult name _ year coverUrl _ _) =
    div_ [class_ "col"] $
        div_ [class_ "card h-100 game-selection-card shadow-sm border-0", onclick_ (T.concat ["openModal('", escapeQuotes name, "', '", maybe "" id coverUrl, "')"])] $ do
            div_ [class_ "position-relative"] $ do
                case coverUrl of
                    Just url -> img_ [src_ url, class_ "card-img-top game-selection-cover", alt_ "Capa do jogo"]
                    Nothing -> div_ [class_ "card-img-top bg-secondary text-white d-flex align-items-center justify-content-center", style_ "height: 180px;"] $
                                    span_ [class_ "small"] "Sem capa"
                div_ [class_ "card-img-overlay d-flex align-items-end p-0"] $
                    div_ [class_ "w-100 p-2 bg-dark bg-opacity-75 text-white"] $
                        h6_ [class_ "card-title m-0 text-truncate"] $ toHtml name

            div_ [class_ "card-body p-2 d-flex justify-content-between align-items-center"] $ do
                span_ [class_ "text-muted small"] $ case year of
                    Just y -> toHtml (show y)
                    Nothing -> "N/A"
                span_ [class_ "badge bg-primary rounded-pill"] "+"

escapeQuotes :: Text -> Text
escapeQuotes = T.replace "'" "\\'" . T.replace "\"" "&quot;"
