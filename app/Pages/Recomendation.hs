{-# LANGUAGE OverloadedStrings #-}

module Pages.Recomendation where

import Lucid
import Data.Text (Text)
import qualified Data.Text as T
import Models.Games (Game(..))
import Api.Igdb (GameResult(..))
import Data.List (sortBy)

-- | Página de Recomendações
recomendPage :: [GameResult] -> Maybe Int -> Maybe Int -> Html ()
recomendPage recommendedGames minYear maxYear = html_ [lang_ "pt-br"] $ do
    head_ $ do
        title_ "Recomendações para Você - Games Backlog"
        meta_ [charset_ "utf-8"]
        meta_ [name_ "viewport", content_ "width=device-width, initial-scale=1"]
        link_ [href_ "https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css", rel_ "stylesheet"]
        style_ customStyle

    body_ $ do
        nav_ [class_ "navbar navbar-expand-lg navbar-dark bg-primary"] $
            div_ [class_ "container"] $ do
                a_ [class_ "navbar-brand", href_ "/"] "🎮 Games Backlog"
                div_ [class_ "navbar-nav ms-auto"] $ do
                    a_ [class_ "nav-link", href_ "/backlog"] "Backlog"

        div_ [class_ "container mt-5 mb-5"] $ do
            h1_ [class_ "mb-4 text-center text-dark fw-bold"] "Recomendações Personalizadas"
            p_ [class_ "text-center text-muted mb-5"] "Baseado nos gêneros e temas que você mais gosta e bem avalia no seu backlog."

            div_ [class_ "card shadow-sm border-0 rounded-4 mb-5"] $
                div_ [class_ "card-body p-4"] $
                    form_ [method_ "get", action_ "/recomend", class_ "row g-3 align-items-end justify-content-center"] $ do
                        div_ [class_ "col-md-3"] $ do
                            label_ [for_ "min_year", class_ "form-label small fw-bold"] "Ano Mínimo"
                            input_ [ type_ "number", name_ "min_year", id_ "min_year", class_ "form-control"
                                   , placeholder_ "Ex: 2010", value_ (maybe "" (T.pack . show) minYear)
                                   , min_ "1950", max_ "2030"]
                        div_ [class_ "col-md-3"] $ do
                            label_ [for_ "max_year", class_ "form-label small fw-bold"] "Ano Máximo"
                            input_ [ type_ "number", name_ "max_year", id_ "max_year", class_ "form-control"
                                   , placeholder_ "Ex: 2024", value_ (maybe "" (T.pack . show) maxYear)
                                   , min_ "1950", max_ "2030"]
                        div_ [class_ "col-md-auto"] $
                            button_ [type_ "submit", class_ "btn btn-primary px-4"] "🔍 Filtrar e Gerar"
                        div_ [class_ "col-md-auto"] $
                            a_ [href_ "/backlog", class_ "btn btn-outline-secondary"] "Voltar"
                        div_ [class_ "col-md-auto"] $
                            a_ [href_ "/migrate-metadata", class_ "btn btn-outline-warning", title_ "Busca gêneros e temas para jogos antigos no seu backlog"] "Sincronizar Perfil"

            if null recommendedGames
                then div_ [class_ "alert alert-info text-center mt-5"] $ do
                    h4_ "Ops! Não conseguimos gerar recomendações agora."
                    p_ "Certifique-se de ter jogos avaliados no seu backlog para que possamos entender seu gosto."
                else div_ [class_ "row row-cols-1 row-cols-md-2 row-cols-lg-3 g-4"] $
                        mapM_ renderRecommendedCard recommendedGames

-- | Renderiza um card simplificado para os jogos recomendados
renderRecommendedCard :: GameResult -> Html ()
renderRecommendedCard (GameResult title platforms year coverUrl genres themes) =
    div_ [class_ "col"] $
        div_ [class_ "card h-100 shadow-sm border-0 rounded-4 overflow-hidden position-relative"] $ do
            form_ [ method_ "post"
                  , action_ "/ignore-recomend"
                  , class_ "position-absolute"
                  , style_ "top: 8px; right: 8px; z-index: 10;"
                  ] $ do
                input_ [type_ "hidden", name_ "title", value_ title]
                button_ [ type_ "submit"
                        , class_ "btn btn-sm btn-light rounded-circle shadow-sm"
                        , style_ "width: 28px; height: 28px; padding: 0; display: flex; align-items: center; justify-content: center; font-size: 14px; opacity: 0.8;"
                        , title_ "Não recomendar este jogo"
                        ] "✖"
                        
            div_ [class_ "d-flex", style_ "height: 160px;"] $ do
                div_ [style_ "width: 120px; min-width: 120px;"] $
                    case coverUrl of
                        Just url -> img_ [src_ url, class_ "h-100 w-100", style_ "object-fit: cover;", alt_ "Capa"]
                        Nothing -> div_ [class_ "bg-secondary h-100 w-100 d-flex align-items-center justify-content-center text-white"] "Sem capa"

                div_ [class_ "p-3 flex-grow-1 d-flex flex-column justify-content-center"] $ do
                    h5_ [class_ "card-title fw-bold mb-1", style_ "font-size: 1.1rem;"] $ toHtml title
                    p_ [class_ "text-muted small mb-1"] $ toHtml $ maybe "" (T.pack . show) year
                    div_ [class_ "mt-2"] $
                        case platforms of
                            [] -> ""
                            (p:_) -> span_ [class_ "badge bg-light text-dark border"] $ toHtml p

            div_ [class_ "card-footer bg-white border-0 pt-2 pb-3 px-3 d-flex justify-content-between align-items-center"] $ do
                div_ [class_ "d-flex flex-wrap gap-1"] $ do
                    mapM_ (\g -> span_ [class_ "badge rounded-pill", style_ "background: #e3f2fd; color: #1976d2; font-size: 0.7rem;"] $ toHtml g) (take 2 genres)
                    mapM_ (\t -> span_ [class_ "badge rounded-pill", style_ "background: #f3e5f5; color: #7b1fa2; font-size: 0.7rem;"] $ toHtml t) (take 1 themes)

                a_ [ href_ $ "https://www.youtube.com/results?search_query=" <> T.replace " " "+" title <> "+review"
                   , target_ "_blank"
                   , class_ "btn btn-sm btn-outline-danger"
                   , style_ "position: relative; z-index: 2; padding: 0.1rem 0.4rem; font-size: 0.75rem;"
                   , title_ "Pesquisar no YouTube"
                   ] "▶"

            a_ [ href_ $ "/add?name=" <> T.replace " " "+" title <> "&source=recomend"
               , class_ "stretched-link"
               ] ""

customStyle :: Text
customStyle = T.concat
    [ "body { background: #f8f9fa; }"
    , ".card { transition: transform 0.2s, box-shadow 0.2s; }"
    , ".card:hover { transform: translateY(-5px); box-shadow: 0 10px 20px rgba(0,0,0,0.1) !important; }"
    , ".badge { font-weight: 500; }"
    ]

-- | Estatísticas de (Nome do Item, Frequência, Soma das Notas)
type StatCollection = [(Text, Int, Double)]

-- | Processa a lista de jogos para gerar estatísticas baseadas em um campo (genres ou themes)
processStats :: (Game -> Maybe Text) -> [Game] -> StatCollection
processStats fieldFunc games =
    let -- Cria pares de (item, score) para cada item encontrado nos campos de cada jogo
        itemsWithScores = concatMap (\g -> map (\it -> (it, score g)) (extractItems $ fieldFunc g)) games
        -- Agrupa e soma as estatísticas
        grouped = foldl updateStats [] itemsWithScores
    in grouped
  where
    extractItems Nothing = []
    extractItems (Just t) = filter (not . T.null) . map T.strip $ T.splitOn "," t

    updateStats :: StatCollection -> (Text, Double) -> StatCollection
    updateStats acc (item, s) =
        case findIndexByName item acc of
            Just idx ->
                let (name, count, scoreSum) = acc !! idx
                    updatedItem = (name, count + 1, scoreSum + s)
                    (before, _:after) = splitAt idx acc
                in updatedItem : (before ++ after)
            Nothing ->
                (item, 1, s) : acc

    findIndexByName _ [] = Nothing
    findIndexByName target coll =
        let indexed = zip [0..] coll
            found = filter (\(_, (name, _, _)) -> name == target) indexed
        in case found of
            ((idx, _):_) -> Just idx
            _ -> Nothing
