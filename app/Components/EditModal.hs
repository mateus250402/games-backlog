{-# LANGUAGE OverloadedStrings #-}

module Components.EditModal where

import Lucid
import Data.Text (Text)
import qualified Data.Text as T

editModal :: Html ()
editModal = do
    div_ [id_ "game-details-modal", class_ "modal", tabindex_ "-1"] $
        div_ [class_ "modal-dialog"] $
            div_ [class_ "modal-content"] $ do
                form_ [id_ "edit-form", method_ "post", action_ ""] $ do
                    div_ [class_ "modal-header"] $ do
                        h5_ [class_ "modal-title"] "Editar Jogo"
                        button_ [type_ "button", class_ "btn-close", data_ "bs-dismiss" "modal", data_ "aria-label" "Close"] ""
                    div_ [class_ "modal-body text-start"] $ do
                        div_ [class_ "text-center mb-3"] $
                            img_ [id_ "modal-cover", src_ "", class_ "img-fluid rounded mx-auto d-block", style_ "max-height: 200px;", alt_ "Capa do Jogo"]

                        div_ [class_ "mb-3"] $ do
                            label_ [class_ "form-label"] "Título"
                            input_ [type_ "text", id_ "modal-title-input", name_ "name", class_ "form-control", required_ ""]

                        div_ [id_ "modal-tags-container", class_ "mb-3"] $ do
                            div_ [id_ "modal-genres-tags", class_ "d-flex flex-wrap gap-1 mb-1"] ""
                            div_ [id_ "modal-themes-tags", class_ "d-flex flex-wrap gap-1"] ""

                        div_ [class_ "mb-3", id_ "modal-score-container"] $ do
                            label_ [class_ "form-label"] "Nota (0-10)"
                            input_ [type_ "number", id_ "modal-score-input", name_ "score", step_ "0.1", min_ "0", max_ "10", class_ "form-control"]

                        div_ [class_ "mb-3"] $ do
                            label_ [class_ "form-label"] "Plataforma"
                            select_ [id_ "modal-platform-input", name_ "platform", class_ "form-select", required_ ""] $ do
                                option_ [value_ "PC"] "PC"
                                option_ [value_ "PlayStation"] "PlayStation"
                                option_ [value_ "Xbox"] "Xbox"
                                option_ [value_ "Nintendo"] "Nintendo"

                        div_ [class_ "mb-3 d-flex gap-4"] $ do
                            div_ [class_ "form-check"] $ do
                                input_ [type_ "checkbox", id_ "modal-played-input", name_ "played", class_ "form-check-input", onclick_ "toggleModalScore()"]
                                label_ [class_ "form-check-label", for_ "modal-played-input"] "Jogado"
                            div_ [class_ "form-check"] $ do
                                input_ [type_ "checkbox", id_ "modal-platinum-input", name_ "platinumed", class_ "form-check-input"]
                                label_ [class_ "form-check-label", for_ "modal-platinum-input"] "Platinado"

                        input_ [type_ "hidden", id_ "modal-cover-url-input", name_ "cover_url"]

                    div_ [class_ "modal-footer d-flex justify-content-between"] $ do
                        button_ [type_ "button", class_ "btn btn-danger", onclick_ "handleDelete()"] "Excluir"
                        div_ $ do
                            button_ [type_ "button", class_ "btn btn-secondary me-2", data_ "bs-dismiss" "modal"] "Cancelar"
                            button_ [type_ "submit", class_ "btn btn-primary"] "Salvar Alterações"

editModalScripts :: Html ()
editModalScripts = script_ $ T.unlines
    [ "let currentGameId = null;"
    , "function showGameDetails(id, title, score, platform, coverUrl, played, platinumed, genres, themes) {"
    , "  currentGameId = id;"
    , "  document.getElementById('edit-form').action = '/edit/' + id;"
    , "  document.getElementById('modal-title-input').value = title;"
    , "  document.getElementById('modal-score-input').value = score;"
    , "  document.getElementById('modal-platform-input').value = platform;"
    , "  document.getElementById('modal-cover-url-input').value = coverUrl;"
    , "  document.getElementById('modal-played-input').checked = (played === 'true');"
    , "  document.getElementById('modal-platinum-input').checked = (platinumed === 'true');"
    , "  toggleModalScore();"
    , ""
    , "  const genresContainer = document.getElementById('modal-genres-tags');"
    , "  const themesContainer = document.getElementById('modal-themes-tags');"
    , "  genresContainer.innerHTML = '';"
    , "  themesContainer.innerHTML = '';"
    , ""
    , "  if (genres) {"
    , "    genres.split(',').forEach(g => {"
    , "      const span = document.createElement('span');"
    , "      span.className = 'badge rounded-pill bg-info text-dark';"
    , "      span.innerText = g.trim();"
    , "      genresContainer.appendChild(span);"
    , "    });"
    , "  }"
    , ""
    , "  if (themes) {"
    , "    themes.split(',').forEach(t => {"
    , "      const span = document.createElement('span');"
    , "      span.className = 'badge rounded-pill bg-light text-dark border';"
    , "      span.innerText = t.trim();"
    , "      themesContainer.appendChild(span);"
    , "    });"
    , "  }"
    , ""
    , "  const coverImg = document.getElementById('modal-cover');"
    , "  if (coverUrl && coverUrl !== '') {"
    , "    coverImg.src = coverUrl;"
    , "    coverImg.style.display = 'block';"
    , "  } else {"
    , "    coverImg.style.display = 'none';"
    , "  }"
    , "  const modal = new bootstrap.Modal(document.getElementById('game-details-modal'));"
    , "  modal.show();"
    , "}"
    , "function toggleModalScore() {"
    , "  const played = document.getElementById('modal-played-input').checked;"
    , "  const scoreInput = document.getElementById('modal-score-input');"
    , "  const scoreContainer = document.getElementById('modal-score-container');"
    , "  const platinumCheck = document.getElementById('modal-platinum-input');"
    , "  if (!played) {"
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
    , "function handleDelete() {"
    , "  if (confirm('Tem certeza que deseja excluir este jogo?')) {"
    , "    const form = document.createElement('form');"
    , "    form.method = 'POST';"
    , "    form.action = '/delete/' + currentGameId;"
    , "    document.body.appendChild(form);"
    , "    form.submit();"
    , "  }"
    , "}"
    ]
