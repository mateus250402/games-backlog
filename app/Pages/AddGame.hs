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
        script_ [src_ "https://unpkg.com/htmx.org@1.9.10"] ("" :: T.Text)
        style_ customStyle

    body_ [class_ "bg-light"] $ do
        script_ modalScripts
        nav_ [class_ "navbar navbar-expand-lg navbar-dark bg-primary"] $ do
            div_ [class_ "container"] $ do
                a_ [class_ "navbar-brand", href_ "/"] "🎮 Games Backlog"
                div_ [class_ "navbar-nav ms-auto"] $ do
                    a_ [class_ "nav-link", href_ "/"] "Início"
                    a_ [class_ "nav-link", href_ "/backlog"] "Backlog"
                    a_ [class_ "nav-link", href_ "/logout"] "Logout"

        div_ [class_ "container mt-5"] $ do
            div_ [class_ "row justify-content-center"] $ do
                div_ [class_ "col-md-8"] $ do
                    div_ [class_ "card shadow-sm border-0 rounded-4 overflow-hidden"] $ do
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
                                               , value_ (maybe "" id maybeName)
                                               , autofocus_
                                               ]
                                        div_ [id_ "search-loading", class_ "htmx-indicator input-group-text bg-white"] $
                                            div_ [class_ "spinner-border spinner-border-sm text-primary", role_ "status"] ""

                            div_ [id_ "search-results", class_ "mt-4 fade-in"] $ do
                                p_ [class_ "text-center text-muted"] "Comece a digitar para ver os resultados aqui..."

                            div_ [class_ "text-center mt-4"] $
                                a_ [href_ "/backlog", class_ "btn btn-link text-decoration-none text-muted"] "Voltar ao Backlog"

        -- Modal HTML (carregamento inicial no AddGame para estar disponível desde o início)
        div_ [id_ "gameModal-update"] $ do
            div_ [id_ "gameModal", class_ "custom-backdrop d-none"] (modalContent (maybe "" id maybeName) maybeSource)

modalContent :: T.Text -> Maybe T.Text -> Html ()
modalContent originalName maybeSource = do
    div_ [class_ "modal-dialog modal-dialog-centered shadow-lg", style_ "width: 100%; max-width: 500px; padding: 15px;"] $ do
        div_ [class_ "modal-content bg-white rounded-3 overflow-hidden w-100"] $ do
            div_ [class_ "modal-header bg-primary text-white p-3 d-flex justify-content-between align-items-center"] $ do
                h5_ [id_ "modalTitle", class_ "modal-title m-0 fw-bold"] "Adicionar Jogo"
                button_ [type_ "button", class_ "btn-close btn-close-white", onclick_ "closeModal()"] ""

            div_ [class_ "modal-body p-4"] $ do
                form_ [method_ "post", action_ "/confirm"] $ do
                    input_ [type_ "hidden", name_ "name", id_ "modalName"]
                    input_ [type_ "hidden", name_ "cover_url", id_ "modalCoverUrl"]
                    input_ [type_ "hidden", name_ "original_name", value_ originalName]
                    case maybeSource of
                        Just src -> input_ [type_ "hidden", name_ "source", value_ src]
                        Nothing -> return ()

                    input_ [type_ "hidden", name_ "played", id_ "hiddenPlayed", value_ "on"]

                    div_ [class_ "mb-3", id_ "score-container"] $ do
                        label_ [class_ "form-label fw-bold"] "Nota (0-10): "
                        input_ [type_ "number", name_ "score", id_ "score-input", min_ "0", max_ "10", step_ "0.1", class_ "form-control", placeholder_ "Sem nota"]

                    div_ [class_ "mb-3"] $ do
                        label_ [class_ "form-label fw-bold"] "Plataforma: "
                        select_ [name_ "platform", required_ "", class_ "form-select"] $ do
                            option_ [value_ "PC"] "PC"
                            option_ [value_ "PlayStation"] "PlayStation"
                            option_ [value_ "Xbox"] "Xbox"
                            option_ [value_ "Nintendo"] "Nintendo"

                    div_ [class_ "mb-4 d-flex gap-4"] $ do
                        div_ [class_ "form-check"] $ do
                            input_ [type_ "checkbox", class_ "form-check-input", id_ "wantToPlayCheck", onclick_ "toggleScore()"]
                            label_ [class_ "form-check-label", for_ "wantToPlayCheck"] "Quero jogar"
                        div_ [class_ "form-check"] $ do
                            input_ [type_ "checkbox", name_ "platinumed", class_ "form-check-input", id_ "platinumCheck"]
                            label_ [class_ "form-check-label", for_ "platinumCheck"] "Platinado"

                    div_ [class_ "d-grid gap-2"] $ do
                        button_ [type_ "submit", class_ "btn btn-primary btn-lg fw-bold"] "Salvar Jogo"
                        button_ [type_ "button", class_ "btn btn-outline-secondary", onclick_ "closeModal()"] "Cancelar"

modalScripts :: T.Text
modalScripts = T.unlines
    [ "function openModal(name, coverUrl) {"
    , "  document.getElementById('modalName').value = name;"
    , "  document.getElementById('modalCoverUrl').value = coverUrl || '';"
    , "  document.getElementById('modalTitle').innerText = 'Detalhes: ' + name;"
    , "  document.getElementById('gameModal').classList.remove('d-none');"
    , "  document.body.classList.add('modal-open');"
    , "}"
    , "function closeModal() {"
    , "  document.getElementById('gameModal').classList.add('d-none');"
    , "  document.body.classList.remove('modal-open');"
    , "}"
    , "function toggleScore() {"
    , "  const wantToPlay = document.getElementById('wantToPlayCheck').checked;"
    , "  const scoreInput = document.getElementById('score-input');"
    , "  const scoreContainer = document.getElementById('score-container');"
    , "  const platinumCheck = document.getElementById('platinumCheck');"
    , "  const hiddenPlayed = document.getElementById('hiddenPlayed');"
    , "  if (wantToPlay) {"
    , "    scoreInput.value = '';"
    , "    scoreInput.disabled = true;"
    , "    scoreContainer.style.opacity = '0.5';"
    , "    platinumCheck.checked = false;"
    , "    platinumCheck.disabled = true;"
    , "    hiddenPlayed.value = '';"
    , "  } else {"
    , "    scoreInput.disabled = false;"
    , "    scoreContainer.style.opacity = '1';"
    , "    platinumCheck.disabled = false;"
    , "    hiddenPlayed.value = 'on';"
    , "  }"
    , "}"
    , "document.addEventListener('htmx:afterSwap', (e) => {"
    , "  if (e.detail.target.id === 'search-results') {"
    , "    toggleScore();"
    , "  }"
    , "});"
    ]

customStyle :: T.Text
customStyle = T.concat
    [ "body { background: #f0f2f5; }"
    , ".htmx-indicator { display: none; }"
    , ".htmx-request .htmx-indicator { display: flex; }"
    , ".htmx-request#search-results { opacity: 0.5; transition: opacity 0.2s; }"
    , ".game-selection-card { transition: transform 0.2s, box-shadow 0.2s; cursor: pointer; border: none; border-radius: 12px; overflow: hidden; }"
    , ".game-selection-card:hover { transform: translateY(-5px); box-shadow: 0 10px 20px rgba(0,0,0,0.1); }"
    , ".game-selection-cover { height: 160px; object-fit: cover; }"
    , ".custom-backdrop { background-color: rgba(0,0,0,0.6); position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; z-index: 1040; display: flex; align-items: center; justify-content: center; }"
    , ".modal-open { overflow: hidden; }"
    , ".fade-in { animation: fadeIn 0.3s ease-in-out; }"
    , "@keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }"
    ]
