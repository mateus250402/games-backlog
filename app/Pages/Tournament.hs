{-# LANGUAGE OverloadedStrings #-}

module Pages.Tournament where

import Lucid
import Models.Games (Game(..))
import Data.Text (Text)
import qualified Data.Text as T

tournamentPage :: [Game] -> Html ()
tournamentPage games = html_ $ do
    head_ $ do
        title_ "O que Jogar? - Tournament - Games Backlog"
        meta_ [charset_ "utf-8"]
        meta_ [name_ "viewport", content_ "width=device-width, initial-scale=1"]
        link_ [rel_ "stylesheet", href_ "https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"]
        script_ [src_ "https://unpkg.com/htmx.org@1.9.10"] ("" :: Text)
        style_ tournamentStyles
    body_ [class_ "bg-light"] $ do
        nav_ [class_ "navbar navbar-expand-lg navbar-dark bg-primary"] $
            div_ [class_ "container"] $ do
                a_ [class_ "navbar-brand", href_ "/"] "🎮 Games Backlog"
                div_ [class_ "navbar-nav ms-auto"] $ do
                    a_ [class_ "nav-link", href_ "/backlog"] "Voltar ao Backlog"

        div_ [class_ "container mt-5 text-center"] $ do
            div_ [id_ "tournament-container"] $
                if length games < 2
                    then div_ [class_ "alert alert-info"] "Você precisa de pelo menos 2 jogos no backlog (não jogados) para iniciar um torneio."
                    else selectionView games

selectionView :: [Game] -> Html ()
selectionView games = div_ [class_ "fade-in"] $ do
    script_ tournamentScripts
    h1_ [class_ "mb-2 fw-bold"] "🏆 O que Jogar?"
    p_ [class_ "text-muted mb-4"] "Selecione os jogos que entrarão na disputa ou use todos"

    form_ [ id_ "tournament-form"
          , data_ "hx-post" "/tournament/start"
          , data_ "hx-target" "#tournament-container"
          , data_ "hx-swap" "innerHTML transition:true"
          ] $ do
        div_ [class_ "mb-4 d-flex justify-content-center gap-2 flex-wrap"] $ do
            button_ [type_ "button", class_ "btn btn-outline-secondary shadow-sm", onclick_ "toggleAll()"] "Selecionar/Desmarcar Todos"
            button_ [type_ "button", class_ "btn btn-info shadow-sm fw-bold", onclick_ "pickRandom()"] "🎲 Sorteio Rápido"
            button_ [type_ "submit", class_ "btn btn-primary btn-lg px-5 fw-bold shadow-sm"] "Iniciar Batalha!"

        div_ [class_ "row row-cols-2 row-cols-md-4 row-cols-lg-6 g-3"] $
            mapM_ gameSelectionCard games

    div_ [id_ "random-picker-overlay", class_ "random-overlay"] $ do
        div_ [id_ "random-card-container", class_ "random-card text-center text-white"] $ do
            h2_ [class_ "mb-4 fw-bold text-warning"] "O destino escolheu..."
            div_ [class_ "d-flex justify-content-center mb-4"] $ do
                div_ [class_ "slot-machine shadow-lg"] $ do
                    div_ [id_ "slot-strip", class_ "slot-strip"] ""
            h3_ [id_ "random-game-name", class_ "mb-4 fw-bold"] ""
            div_ [class_ "d-flex justify-content-center gap-3"] $ do
                button_ [type_ "button", class_ "btn btn-outline-light btn-lg", onclick_ "hideRandom()"] "Tentar de Novo"
                button_ [type_ "button", class_ "btn btn-warning btn-lg fw-bold px-4", onclick_ "confirmRandom()"] "BORAAA!"

gameSelectionCard :: Game -> Html ()
gameSelectionCard g = div_ [class_ "col"] $ do
    div_ [class_ "card h-100 selection-card shadow-sm"] $ do
        label_ [class_ "h-100 cursor-pointer"] $ do
            input_ [type_ "checkbox", name_ "game_ids", value_ (T.pack $ show $ gameId g), checked_, class_ "tournament-checkbox d-none"]
            case cover_url g of
                Just url -> img_ [src_ url, class_ "card-img-top selection-img", alt_ (title g)]
                Nothing -> div_ [class_ "bg-secondary text-white d-flex align-items-center justify-content-center selection-img"] "Sem Capa"
            div_ [class_ "card-body p-2"] $ do
                div_ [class_ "small fw-bold text-truncate"] (toHtml $ title g)

battleView :: Game -> Game -> [Int] -> Int -> Html ()
battleView g1 g2 remainingIds total = div_ [class_ "fade-in text-center px-2"] $ do
    h2_ [class_ "mb-3 mb-md-4 fw-bold tournament-title"] "Qual você prefere jogar?"
    let remaining = length remainingIds
    div_ [class_ "progress mb-4 shadow-sm", style_ "height: 12px; border-radius: 6px;"] $
        div_ [class_ "progress-bar bg-warning progress-bar-striped progress-bar-animated", role_ "progressbar", style_ (T.concat ["width: ", T.pack $ show $ (100 * (total - remaining) `div` total), "%"])] ""

    div_ [class_ "battle-container d-flex flex-column flex-md-row justify-content-center align-items-center gap-3 gap-md-4 mb-5"] $ do
        div_ [class_ "battle-wrapper w-100"] $ battleCard g1 remainingIds total
        div_ [class_ "vs-badge shadow-lg"] "VS"
        div_ [class_ "battle-wrapper w-100"] $ battleCard g2 remainingIds total

battleCard :: Game -> [Int] -> Int -> Html ()
battleCard g remainingIds total = div_ [ class_ "card battle-card shadow-lg hover-scale cursor-pointer"
                    , data_ "hx-post" "/tournament/vote"
                    , data_ "hx-vals" (T.concat [ "{\"winner_id\": \"", T.pack $ show $ gameId g
                                              , "\", \"remaining_ids\": \"", T.intercalate "," (map (T.pack . show) remainingIds)
                                              , "\", \"total_count\": \"", T.pack $ show total, "\"}"
                                              ])
                    , data_ "hx-target" "#tournament-container"
                    , data_ "hx-swap" "innerHTML transition:true"
                    ] $ do
    div_ [class_ "position-relative overflow-hidden"] $ do
        case cover_url g of
            Just url -> img_ [src_ url, class_ "battle-img", alt_ (title g)]
            Nothing -> div_ [class_ "bg-secondary text-white d-flex align-items-center justify-content-center battle-img"] "Sem Capa"
        div_ [class_ "battle-card-overlay d-md-none"] $ do
             h4_ [class_ "text-white fw-bold m-0"] (toHtml $ title g)

    div_ [class_ "card-body p-2 p-md-3 bg-white d-none d-md-block"] $ do
        h4_ [class_ "card-title fw-bold m-0 text-truncate"] (toHtml $ title g)
        span_ [class_ "badge bg-primary mt-1"] (toHtml $ platform g)

winnerView :: Game -> Html ()
winnerView g = div_ [class_ "fade-in text-center py-5"] $ do
    h1_ [class_ "display-3 mb-4"] "🎉 Temos um vencedor!"
    div_ [class_ "row justify-content-center mb-4"] $ do
        div_ [class_ "col-md-5"] $ do
            div_ [class_ "card shadow-lg border-warning border-4 overflow-hidden"] $ do
                case cover_url g of
                    Just url -> img_ [src_ url, class_ "img-fluid", alt_ (title g)]
                    Nothing -> div_ [class_ "bg-secondary text-white p-5"] "Sem Capa"
                div_ [class_ "card-body bg-white"] $ do
                    h2_ [class_ "fw-bold"] (toHtml $ title g)
                    p_ [class_ "lead"] $ "Você deve começar a jogar este hoje!"

    div_ [class_ "d-flex justify-content-center gap-3"] $ do
        a_ [href_ "/backlog", class_ "btn btn-outline-primary btn-lg"] "Voltar ao Backlog"
        a_ [href_ "/tournament", class_ "btn btn-primary btn-lg"] "Novo Torneio"

tournamentStyles :: Text
tournamentStyles = T.concat
    [ ".selection-img { height: 150px; object-fit: cover; transition: opacity 0.2s; }"
    , ".selection-card { border: 4px solid transparent; transition: all 0.2s; }"
    , ".cursor-pointer { cursor: pointer; }"
    , ".battle-img { width: 100%; height: 450px; object-fit: cover; display: block; }"
    , ".vs-badge { background: #0d6efd; color: white; width: 60px; height: 60px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 900; font-size: 1.5rem; z-index: 5; flex-shrink: 0; border: 4px solid white; margin: -20px 0; }"
    , ".battle-wrapper { max-width: 350px; }"
    , "@media (max-width: 768px) { "
    , "  .battle-img { height: 280px; } "
    , "  .vs-badge { width: 50px; height: 50px; font-size: 1.2rem; margin: -25px 0; } "
    , "  .tournament-title { font-size: 1.4rem; } "
    , "  .battle-wrapper { max-width: 100%; } "
    , "}"
    , ".battle-card { border: none; border-radius: 15px; overflow: hidden; transition: transform 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275), box-shadow 0.2s; }"
    , ".battle-card:hover { transform: scale(1.05); z-index: 2; box-shadow: 0 20px 40px rgba(0,0,0,0.3) !important; }"
    , ".battle-card-overlay { position: absolute; bottom: 0; left: 0; right: 0; background: linear-gradient(transparent, rgba(0,0,0,0.8)); padding: 20px 15px 10px; text-shadow: 1px 1px 3px rgba(0,0,0,0.5); }"
    , ".hover-scale { transition: transform 0.2s; }"
    , ".fade-in { animation: fadeIn 0.4s ease-in-out; }"
    , "@keyframes fadeIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }"
    , "body.modal-open { overflow: hidden; }"
    , ".tournament-checkbox:checked ~ .selection-img { opacity: 1; filter: none; }"
    , ".tournament-checkbox:not(:checked) ~ .selection-img { opacity: 0.3; filter: grayscale(1); }"
    , ".tournament-checkbox:checked ~ .card-body { background: #0d6efd !important; color: white !important; }"
    , ".tournament-checkbox:not(:checked) ~ .card-body { background: white; color: #666; }"
    , ".random-overlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.85); z-index: 2000; display: none; align-items: center; justify-content: center; backdrop-filter: blur(8px); }"
    , ".random-card { transform: scale(0.5); opacity: 0; transition: all 0.5s cubic-bezier(0.34, 1.56, 0.64, 1); }"
    , ".random-card.show { transform: scale(1); opacity: 1; }"
    , ".slot-machine { height: 300px; overflow: hidden; position: relative; width: 200px; border: 4px solid #ffc107; border-radius: 12px; background: #222; }"
    , ".slot-strip { position: absolute; top: 0; left: 0; width: 100%; transition: top 3s cubic-bezier(0.45, 0.05, 0.55, 0.95); }"
    , ".slot-item { height: 300px; width: 100%; object-fit: cover; }"
    ]

tournamentScripts :: Text
tournamentScripts = T.unlines
    [ "function toggleAll() {"
    , "  const checkboxes = document.querySelectorAll('.tournament-checkbox');"
    , "  const allChecked = Array.from(checkboxes).every(c => c.checked);"
    , "  checkboxes.forEach(c => c.checked = !allChecked);"
    , "}"
    , "let lastSelectedId = null;"
    , "function pickRandom() {"
    , "  const checkboxes = Array.from(document.querySelectorAll('.tournament-checkbox'));"
    , "  if (checkboxes.length === 0) return alert('Selecione ao menos um jogo para sortear!');"
    , ""
    , "  const overlay = document.getElementById('random-picker-overlay');"
    , "  const strip = document.getElementById('slot-strip');"
    , "  const container = document.getElementById('random-card-container');"
    , "  const nameDisplay = document.getElementById('random-game-name');"
    , ""
    , "  const randomIdx = Math.floor(Math.random() * checkboxes.length);"
    , "  const selectedInput = checkboxes[randomIdx];"
    , "  const gameCard = selectedInput.closest('.card');"
    , "  const gameTitle = gameCard.querySelector('.small').innerText;"
    , "  const gameImg = gameCard.querySelector('.selection-img').src;"
    , "  lastSelectedId = selectedInput.value;"
    , ""
    , "  strip.innerHTML = '';"
    , "  strip.style.transition = 'none';"
    , "  strip.style.top = '0px';"
    , ""
    , "  for(let i=0; i<20; i++) {"
    , "    const img = document.createElement('img');"
    , "    const randImg = checkboxes[Math.floor(Math.random() * checkboxes.length)].closest('.card').querySelector('.selection-img').src;"
    , "    img.src = (i === 19) ? gameImg : randImg;"
    , "    img.className = 'slot-item';"
    , "    strip.appendChild(img);"
    , "  }"
    , ""
    , "  overlay.style.display = 'flex';"
    , "  setTimeout(() => {"
    , "    strip.style.transition = 'top 2.5s cubic-bezier(0.1, 0, 0.1, 1)';"
    , "    strip.style.top = '-' + (19 * 300) + 'px';"
    , "  }, 50);"
    , ""
    , "  setTimeout(() => {"
    , "    nameDisplay.innerText = gameTitle;"
    , "    container.classList.add('show');"
    , "  }, 2600);"
    , "}"
    , ""
    , "function hideRandom() {"
    , "  document.getElementById('random-picker-overlay').style.display = 'none';"
    , "  document.getElementById('random-card-container').classList.remove('show');"
    , "}"
    , ""
    , "function confirmRandom() {"
    , "  const checkboxes = document.querySelectorAll('.tournament-checkbox');"
    , "  checkboxes.forEach(c => c.checked = (c.value === lastSelectedId));"
    , "  document.getElementById('tournament-form').submit();"
    , "}"
    ]
