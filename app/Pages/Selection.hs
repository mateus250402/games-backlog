{-# LANGUAGE OverloadedStrings #-}

module Pages.Selection where

import Lucid
import Data.Text (Text)
import qualified Data.Text as T
import Api.Igdb (GameResult(..))

gameSelectionPage :: Text -> Text -> Text -> Bool -> Bool -> Maybe Text -> [GameResult] -> Html ()
gameSelectionPage originalName _ _ _ _ maybeSource gameResults = html_ $ do
    head_ $ do
        title_ "Selecionar Jogo - Games Backlog"
        meta_ [charset_ "utf-8"]
        meta_ [name_ "viewport", content_ "width=device-width, initial-scale=1"]
        link_ [rel_ "stylesheet", href_ "https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"]
        style_ customStyle

    body_ [] $ do
        nav_ [class_ "navbar navbar-expand-lg navbar-dark bg-primary"] $
            div_ [class_ "container"] $
                a_ [class_ "navbar-brand", href_ "/"] "🎮 Games Backlog"

        div_ [class_ "container mt-5"] $ do
            h1_ [class_ "mb-4 text-center text-dark"] "Selecionar o jogo correto"
            p_ [class_ "text-center text-muted mb-4"] $ "Encontramos " <> toHtml (show $ length gameResults) <> " jogos com o nome \"" <> toHtml originalName <> "\". Clique no correto para adicionar os detalhes:"

            div_ [class_ "row"] $
                mapM_ (gameSelectionCard maybeSource) gameResults

            div_ [class_ "text-center mt-4 mb-5"] $
                a_ [href_ "/add", class_ "btn btn-secondary"] "Nova Pesquisa"

        -- Modal HTML (escondido por padrão)
        div_ [id_ "gameModal", class_ "custom-backdrop d-none"] $ do
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

                            -- Campo oculto para enviar 'played' para o /confirm ao invés de 'want_to_play'
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

        script_ $ T.unlines
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
            , "window.onload = toggleScore;"
            ]

gameSelectionCard :: Maybe Text -> GameResult -> Html ()
gameSelectionCard _ (GameResult name _ year coverUrl _ _) =
    div_ [class_ "col-md-6 col-lg-4 mb-4"] $
        div_ [class_ "card h-100 game-selection-card", onclick_ (T.concat ["openModal('", escapeQuotes name, "', '", maybe "" id coverUrl, "')"]), style_ "cursor: pointer;"] $ do
            case coverUrl of
                Just url -> img_ [src_ url, class_ "card-img-top game-selection-cover", alt_ "Capa do jogo"]
                Nothing -> div_ [class_ "card-img-top bg-secondary text-white d-flex align-items-center justify-content-center", style_ "height: 200px;"] "Sem capa"

            div_ [class_ "card-body d-flex flex-column"] $ do
                h5_ [class_ "card-title"] $ toHtml name
                p_ [class_ "card-text flex-grow-1"] $ do
                    case year of
                        Just y -> do
                            strong_ "Ano: "
                            toHtml $ show y
                        Nothing -> "Ano não informado"
                button_ [type_ "button", class_ "btn btn-primary w-100 mt-auto"] "Adicionar..."

escapeQuotes :: Text -> Text
escapeQuotes = T.replace "'" "\\'" . T.replace "\"" "&quot;"

customStyle :: Text
customStyle = T.concat
    [ "body { background: #f8f9fa; }"
    , ".game-selection-card { transition: transform 0.2s, box-shadow 0.2s; border: 2px solid transparent; }"
    , ".game-selection-card:hover { transform: translateY(-5px); box-shadow: 0 8px 16px rgba(0,0,0,0.1); border-color: #0d6efd; }"
    , ".game-selection-cover { height: 200px; object-fit: cover; }"
    , ".modal-open { overflow: hidden; }"
    , ".custom-backdrop { background-color: rgba(0,0,0,0.6); position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; z-index: 1040; display: flex; align-items: center; justify-content: center; }"
    ]
