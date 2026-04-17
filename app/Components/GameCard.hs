{-# LANGUAGE OverloadedStrings #-}

module Components.GameCard where

import Lucid
import Data.Text (Text)
import qualified Data.Text as T
import Models.Games (Game(..))

-- Componente de Card de Jogo reutilizável
-- Aceita um Game e um booleano que indica se o card deve ser clicável para abrir o modal de edição
gameCard :: Game -> Bool -> Html ()
gameCard (Game gId gTitle gScore gPlatform gCoverUrl gPlayed gPlatinumed gGenres gThemes) isClickable =
    let (cardBg, cardBorder) = if not gPlayed
            then ("#f0f0f0", "#999999")
            else case gPlatform of
                "PlayStation" -> ("#e3ecfa", "#0050d9")
                "Nintendo"    -> ("#ffeaea", "#e60012")
                "PC"          -> ("#e6e6e6ff", "#303030ff")
                "Xbox"        -> ("#eafaf1", "#107c10")
                _             -> ("#f8f9fa", "#6c757d")

        cardStyle = T.concat
            [ "background:", if gPlatinumed then "rgba(0,0,0,0.05)" else cardBg, ";"
            , "border-bottom: 8px solid ", cardBorder, ";"
            , if not gPlayed then "opacity: 0.6; filter: grayscale(0.5);" else ""
            , if isClickable then "cursor: pointer;" else ""
            ]

        onClickAttr = if isClickable
            then [ onclick_ $ T.concat
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
                , "', '"
                , maybe "" (T.replace "'" "\\'") gGenres
                , "', '"
                , maybe "" (T.replace "'" "\\'") gThemes
                , "')"
                ]
            ]
            else []

    in div_ ([ class_ "game-card position-relative h-100 d-flex flex-column"
             , style_ cardStyle
             ] ++ onClickAttr) $ do
        div_ [class_ "game-img-col"] $ do
            if gPlatinumed
                then div_ [class_ "platinum-tag"] "🏆"
                else ""
            case gCoverUrl of
                Just url -> img_ [src_ url, class_ "game-cover", alt_ "Capa do jogo", style_ (if not gPlayed then "filter: grayscale(1) contrast(0.8);" else "")]
                Nothing  -> div_ [class_ "bg-secondary text-white text-center rounded-top w-100", style_ "height:180px; display:flex; align-items:center; justify-content:center;"] "Sem capa disponível"
        div_ [class_ "game-col"] $ do
            div_ [class_ "game-title"] $ toHtml gTitle
            if gScore > 0
                then div_ [class_ "game-info"] $ strong_ "Nota: " <> toHtml (show gScore)
                else ""

-- Estilos compartilhados para o GameCard
gameCardStyles :: Text
gameCardStyles = T.concat
    [ ".game-card { border-radius: 1rem; box-shadow: 0 2px 8px rgba(0,0,0,0.07); border: 1px solid #e0e0e0; color: #222; overflow: hidden; position: relative; padding: 0; background: #fff; transition: box-shadow 0.2s; height: 100%; display: flex; flex-direction: column; }"
    , ".game-card:hover { box-shadow: 0 6px 16px rgba(0,0,0,0.12); }"
    , ".game-cover { border-radius: 1rem 1rem 0 0; background: #222; height: 200px; width: 100%; object-fit: cover; display: block; transition: filter 0.3s ease; }"
    , ".game-title { font-size: 1rem; line-height: 1.2; font-weight: bold; margin-bottom: 0.2rem; }"
    , ".game-info { font-size: 0.8rem; line-height: 1.1; }"
    , ".game-col { padding: 0.75rem !important; display: flex; flex-direction: column; justify-content: flex-start; flex-grow: 1; }"
    , ".game-img-col { padding: 0 !important; display: flex; align-items: center; justify-content: flex-start; background: #f0f0f0; width: 100%; height: 200px; }"
    , ".platinum-tag { position: absolute; top: 8px; right: 8px; background: rgba(0,0,0,0.3); color: #4a6fa5; padding: 2px 10px; font-size: 1.1rem; border-radius: 0.8rem; z-index: 20; font-weight: 800; border: 1px solid rgba(0,0,0,0.2); filter: sepia(1) hue-rotate(180deg) brightness(1.1) contrast(1.2); }"
    ]

-- Estilos específicos para responsividade (mobile)
gameCardMobileStyles :: Text
gameCardMobileStyles = T.concat
    [ "@media (max-width: 576px) { "
    , "  .game-card { height: 100%; min-height: 250px; border-radius: 1rem; margin-bottom: 0px; } "
    , "  .game-title { font-size: 1rem; line-height: 1.2; margin-bottom: 4px !important; } "
    , "  .game-info { font-size: 0.85rem; } "
    , "  .game-img-col, .game-cover { width: 100% !important; height: 180px !important; border-radius: 1rem 1rem 0 0 !important; } "
    , "  .game-col { padding: 0.6rem !important; flex-grow: 1; display: flex; flex-direction: column; justify-content: flex-start; } "
    , "  .platinum-tag { top: 6px; right: 6px; font-size: 1rem; padding: 2px 8px; } "
    , "}"
    ]
