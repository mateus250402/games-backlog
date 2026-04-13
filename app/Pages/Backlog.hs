{-# LANGUAGE OverloadedStrings #-}

module Pages.Backlog where

import Lucid
import Models.Games (Game(..))
import Data.Text (Text)
import qualified Data.Text as T

backlogPage :: [Game] -> Html ()
backlogPage games = html_ $ do
    head_ $ do
        title_ "Meu Backlog - Games Backlog"
        meta_ [charset_ "utf-8"]
        link_ [rel_ "stylesheet", href_ "https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"]
        style_ customStyle
    body_ [] $ do
        div_ [id_ "game-details-modal", class_ "modal", tabindex_ "-1"] $
            div_ [class_ "modal-dialog"] $
                div_ [class_ "modal-content"] $ do
                    div_ [class_ "modal-header"] $ do
                        h5_ [class_ "modal-title", id_ "modal-title"] ""
                        button_ [type_ "button", class_ "btn-close", data_ "bs-dismiss" "modal", data_ "aria-label" "Close"] ""
                    div_ [class_ "modal-body text-center"] $ do
                        img_ [id_ "modal-cover", src_ "", class_ "img-fluid mb-3 rounded mx-auto d-block", style_ "max-height: 300px;", alt_ "Capa do Jogo"]
                        p_ $ do
                            strong_ "Nota: "
                            span_ [id_ "modal-score"] ""
                        p_ $ do
                            strong_ "Plataforma: "
                            span_ [id_ "modal-platform"] ""
                    div_ [class_ "modal-footer"] $ do
                        button_ [type_ "button", class_ "btn btn-secondary", data_ "bs-dismiss" "modal"] "Fechar"
                        form_ [id_ "delete-form", method_ "post", action_ ""] $
                            button_ [type_ "submit", class_ "btn btn-danger", onclick_ "return confirm('Tem certeza que deseja excluir este jogo?')"] "Excluir"

        script_ [src_ "https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"] ("" :: Text)
        script_ $ T.unlines
            [ "function showGameDetails(id, title, score, platform, coverUrl) {"
            , "  document.getElementById('modal-title').innerText = title;"
            , "  document.getElementById('modal-score').innerText = score;"
            , "  document.getElementById('modal-platform').innerText = platform;"
            , "  const coverImg = document.getElementById('modal-cover');"
            , "  if (coverUrl && coverUrl !== '') {"
            , "    coverImg.src = coverUrl;"
            , "    coverImg.style.display = 'block';"
            , "  } else {"
            , "    coverImg.style.display = 'none';"
            , "  }"
            , "  document.getElementById('delete-form').action = '/delete/' + id;"
            , "  const modal = new bootstrap.Modal(document.getElementById('game-details-modal'));"
            , "  modal.show();"
            , "}"
            ]

        nav_ [class_ "navbar navbar-expand-lg navbar-dark bg-primary"] $
            div_ [class_ "container"] $
                a_ [class_ "navbar-brand", href_ "/"] "🎮 Games Backlog"
        div_ [class_ "container-mobile mt-5"] $ do
            h1_ [class_ "mb-4 text-center text-dark fw-bold"] "Meu Backlog"

            div_ [class_ "mb-4 text-center"] $ do
                a_ [href_ "/add", class_ "btn btn-success me-2"] "Adicionar Jogo"
                a_ [href_ "/", class_ "btn btn-outline-primary"] "Home"

            form_ [method_ "get", action_ "/backlog", class_ "mb-4 d-flex justify-content-center"] $ do
                input_ [type_ "text", name_ "search", placeholder_ "Pesquisar jogos...", class_ "form-control me-2", style_ "max-width: 300px;"]
                select_ [name_ "platform", class_ "form-select w-auto me-2"] $ do
                    option_ [value_ ""] "Todas"
                    option_ [value_ "PlayStation"] "PlayStation"
                    option_ [value_ "Nintendo"] "Nintendo"
                    option_ [value_ "PC"] "PC"
                    option_ [value_ "Xbox"] "Xbox"
                select_ [name_ "sort", class_ "form-select w-auto me-2"] $ do
                    option_ [value_ ""] "Sem ordenação"
                    option_ [value_ "score"] "Ordenar por nota"
                button_ [type_ "submit", class_ "btn btn-primary"] "Filtrar"

            h2_ [class_ "mt-4 mb-3 text-secondary"] "Jogos Salvos"
            if null games
                then p_ [class_ "text-center text-muted fs-4"] "Nenhum jogo salvo ainda."
                else div_ [class_ "d-flex flex-row flex-wrap align-items-start w-100", style_ ""] $
                        mapM_ backlogCard games

backlogCard :: Game -> Html ()
backlogCard (Game gId gTitle gScore gPlatform gCoverUrl gPlayed gPlatinumed) =
    let (cardBg, cardBorder) = if not gPlayed
            then ("#f0f0f0", "#999999")
            else case gPlatform of
                "PlayStation" -> ("#e3ecfa", "#0050d9")
                "Nintendo"    -> ("#ffeaea", "#e60012")
                "PC"          -> ("#e6e6e6ff", "#303030ff")
                "Xbox"        -> ("#eafaf1", "#107c10")
                _             -> ("#f8f9fa", "#6c757d")
        cardStyle = T.concat
            [ "background:", cardBg, ";"
            , "border-bottom: 14px solid ", cardBorder, ";"
            , "margin-bottom: 12px;"
            , if not gPlayed then "opacity: 0.6; filter: grayscale(0.5);" else ""
            ]
        onClickAttr = T.concat
            [ "showGameDetails('"
            , T.pack (show gId)
            , "', '"
            , T.replace "'" "\\'" gTitle
            , "', '"
            , T.pack (show gScore)
            , "', '"
            , gPlatform
            , "', '"
            , maybe "" id gCoverUrl
            , "', '"
            , if gPlayed then "true" else "false"
            , "', '"
            , if gPlatinumed then "true" else "false"
            , "')"
            ]
    in div_ [class_ "game-card-container", style_ "flex: 1 1 31%; max-width: 31%; min-width: 300px; margin-right: 2%; margin-left: 0;"] $
        div_ [ class_ "game-card mb-2 position-relative"
             , style_ (cardStyle <> "cursor: pointer;")
             , onclick_ onClickAttr
             ] $ do
            div_ [class_ "game-img-col"] $
                case gCoverUrl of
                    Just url -> img_ [src_ url, class_ "game-cover", alt_ "Capa do jogo", style_ (if not gPlayed then "filter: sepia(0.2);" else "")]
                    Nothing  -> div_ [class_ "bg-secondary text-white text-center rounded w-100", style_ "height:140px; display:flex; align-items:center; justify-content:center;"] "Sem capa disponível"
            div_ [class_ "game-col flex-grow-1"] $ do
                div_ [class_ "game-title mb-0"] $ toHtml gTitle
                if gScore > 0
                    then div_ [class_ "game-info mb-0"] $ strong_ "Nota: " <> toHtml (show gScore)
                    else ""
                div_ [class_ "game-info mb-0"] $ strong_ "Plataforma: " <> toHtml gPlatform

customStyle :: Text
customStyle = T.concat
    [ "body { background: #f8f9fa; }"
    , ".game-card { border-radius: 1.5rem 1.5rem 2.5rem 2.5rem; box-shadow: 0 4px 16px 0 rgba(31,38,135,0.10); border: 1px solid #e0e0e0; color: #222; overflow: hidden; position: relative; padding: 0; background: #fff; transition: box-shadow 0.2s; height: 140px; display: flex; }"
    , ".game-card:hover { box-shadow: 0 8px 32px 0 rgba(31,38,135,0.18); }"
    , ".game-card-bottom { height: 14px; width: 100%; position: absolute; left: 0; bottom: 0; border-radius: 0 0 2.5rem 2.5rem; }"
    , ".game-cover { border-radius: 1.5rem 0 0 1.5rem; box-shadow: 0 2px 8px 0 rgba(0,0,0,0.06); background: #222; height: 140px; width: 120px; object-fit: cover; display: block; }"
    , ".game-title { font-size: 1.25rem; line-height: 1.2;  font-weight: bold; letter-spacing: 0.5px; }"
    , ".game-info { font-size: 0.95rem; line-height: 1.1; }"
    , ".game-col { padding: 0.8rem 1rem !important; display: flex; flex-direction: column; justify-content: center; height: 140px; }"
    , ".game-img-col { padding: 0 !important; display: flex; align-items: center; justify-content: flex-start; background: #f0f0f0; width: 120px; height: 140px; }"
    , ".delete-form { position: absolute; top: 8px; right: 8px; z-index: 10; margin: 0; }"
    , ".delete-btn { width: 28px; height: 28px; border-radius: 50%; padding: 0; display: flex; align-items: center; justify-content: center; font-size: 18px; font-weight: bold; line-height: 1; opacity: 0.6; transition: opacity 0.2s, transform 0.2s; background: transparent; border: none; color: #666; }"
    , ".delete-btn:hover { opacity: 1; transform: scale(1.1); color: #dc3545; }"
    , ".game-card:hover .delete-btn { opacity: 0.8; }"
    , ".container-mobile { width: 100%; padding-right: var(--bs-gutter-x, .75rem); padding-left: var(--bs-gutter-x, .75rem); margin-right: auto; margin-left: auto; } @media (min-width: 576px) { .container-mobile { max-width: 540px; } } @media (min-width: 768px) { .container-mobile { max-width: 720px; } } @media (min-width: 992px) { .container-mobile { max-width: 960px; } } @media (min-width: 1200px) { .container-mobile { max-width: 1140px; } } @media (min-width: 1400px) { .container-mobile { max-width: 1320px; } } @media (max-width: 576px) { .container-mobile { padding-left: 5px; padding-right: 5px; max-width: 100%; } }"
    , "@media (max-width: 576px) { .game-card-container { flex: 1 1 100% !important; max-width: 100% !important; } .game-title { font-size: 1.1rem; max-width: 240px; display: block; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; } .game-info { font-size: 0.85rem; } .game-card { height: 120px; } .game-img-col, .game-cover { width: 100px; height: 120px; } .game-col { height: 120px; } }"
    ]
