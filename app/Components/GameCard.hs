{-# LANGUAGE OverloadedStrings #-}

module Components.GameCard where

import Lucid
import Data.Text (Text)
import qualified Data.Text as T
import Models.Games (Game(..))

-- Componente de Card de Jogo reutilizável
-- Aceita um Game e um booleano que indica se o card deve ser clicável para abrir o modal de edição
gameCard :: Game -> Bool -> Html ()
gameCard (Game gId gTitle gScore gPlatform gCoverUrl gPlayed gPlatinumed) isClickable =
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
                , "')"
                ]
            ]
            else []

    in div_ ([ class_ "game-card mb-2 position-relative"
             , style_ cardStyle
             ] ++ onClickAttr) $ do
        if gPlatinumed
            then div_ [class_ "platinum-tag"] "🏆"
            else ""
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

-- Estilos compartilhados para o GameCard
gameCardStyles :: Text
gameCardStyles = T.concat
    [ ".game-card { border-radius: 1.5rem 1.5rem 2.5rem 2.5rem; box-shadow: 0 4px 16px 0 rgba(31,38,135,0.10); border: 1px solid #e0e0e0; color: #222; overflow: hidden; position: relative; padding: 0; background: #fff; transition: box-shadow 0.2s; height: 140px; display: flex; }"
    , ".game-card:hover { box-shadow: 0 8px 32px 0 rgba(31,38,135,0.18); }"
    , ".game-cover { border-radius: 1.5rem 0 0 1.5rem; box-shadow: 0 2px 8px 0 rgba(0,0,0,0.06); background: #222; height: 140px; width: 120px; object-fit: cover; display: block; }"
    , ".game-title { font-size: 1.25rem; line-height: 1.2;  font-weight: bold; letter-spacing: 0.5px; }"
    , ".game-info { font-size: 0.95rem; line-height: 1.1; }"
    , ".game-col { padding: 0.8rem 1rem !important; display: flex; flex-direction: column; justify-content: center; height: 140px; }"
    , ".game-img-col { padding: 0 !important; display: flex; align-items: center; justify-content: flex-start; background: #f0f0f0; width: 120px; height: 140px; }"
    , ".platinum-tag { position: absolute; top: 0; right: 0; background: #d0e0f0; color: #4a6fa5; padding: 2px 10px; font-size: 1.1rem; border-radius: 0 1.5rem 0 0.8rem; z-index: 20; font-weight: 800; border-left: 1px solid #a5c2e1; border-bottom: 1px solid #a5c2e1; box-shadow: -1px 1px 4px rgba(74,111,165,0.2); filter: sepia(1) hue-rotate(180deg) brightness(1.1) contrast(1.2); }"
    ]

-- Estilos específicos para responsividade (mobile)
gameCardMobileStyles :: Text
gameCardMobileStyles = T.concat
    [ "@media (max-width: 576px) { "
    , "  .game-card { height: 120px; } "
    , "  .game-title { font-size: 1.1rem; max-width: 240px; display: block; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; } "
    , "  .game-info { font-size: 0.85rem; } "
    , "  .game-img-col, .game-cover { width: 100px; height: 120px; } "
    , "  .game-col { height: 120px; } "
    , "}"
    ]
