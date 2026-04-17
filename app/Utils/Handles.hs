{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# OPTIONS_GHC -Wno-deprecations #-}

module Utils.Handles where

import Web.Scotty (ActionM, body, html, redirect, pathParam, queryParam, queryParamMaybe, header)
import qualified Data.Text as T
import qualified Data.Text.Lazy as TL
import Control.Monad.IO.Class (liftIO)
import Data.List (sortBy)
import Lucid (renderText)
import Control.Exception (SomeException)
import Text.Read (readMaybe)

-- Módulos internos
import qualified DB.DB as DB
import qualified Utils.Session as Session
import qualified Utils.Format as Format
import qualified Pages.Confirm as Confirm
import qualified Pages.Backlog as Backlog
import qualified Pages.Index as Index
import qualified Pages.Login as Login
import qualified Pages.Register as Register
import qualified Pages.AddGame as AddGame
import qualified Api.Igdb as Igdb
import qualified Utils.Data as Dt
import qualified Models.Games as Game
import qualified Pages.Selection as Selection
import qualified Pages.Recomendation as Recomend
import qualified Pages.Tournament as Tournament

postLogin :: ActionM ()
postLogin = do
    requestBody <- body
    let formData = Format.parseFormData requestBody

    case (lookup "email" formData, lookup "password" formData) of -- Procura email e senha no formData
        (Just email, Just password) -> do -- lookup pode retornar Nothing ou Just valor
            result <- liftIO $ DB.authenticateUser (T.pack email) (T.pack password)
            case result of
                Right userId -> do
                    Session.sessionInsert "user_id" (show userId)
                    redirect "/"
                Left msg -> do
                    html $ TL.pack $ "Erro: " ++ msg
        _ -> html "Email ou senha incorretos" -- Captura qualquer outro caso

postRegister :: ActionM ()
postRegister = do
    requestBody <- body
    let formData = Format.parseFormData requestBody

    case (lookup "email" formData, lookup "password" formData) of -- Procura email e senha no formData
        (Just email, Just password) -> do
            result <- liftIO $ DB.insertUser (T.pack email) (T.pack password)
            case result of
                Right _ -> redirect "/login"
                Left msg -> html $ TL.pack $ "Erro: " ++ msg
        _ -> html "Erro: email ou senha não encontrados" -- Captura qualquer outro caso

postAdd :: ActionM ()
postAdd = do
    requestBody <- body
    let formData = Format.parseFormData requestBody
    let wantToPlay = lookup "want_to_play" formData == Just "on"
    let played = not wantToPlay
    let platinumed = lookup "platinumed" formData == Just "on"
    let maybeSource = lookup "source" formData

    case (lookup "name" formData, lookup "platform" formData) of -- Procura name e platform no formData
        (Just name, Just platform) -> do
            let score = maybe "" id (lookup "score" formData)
            let finalScore = if score == "" || wantToPlay then "0" else score
            gameResults <- liftIO $ Igdb.searchMultipleGames (T.pack name)

            case gameResults of
                [] ->  -- Nenhum jogo encontrado, redireciona para a página de confirmação sem cover_url
                    redirect $ TL.concat
                        [ "/confirm?name=", TL.pack name
                        , "&score=", TL.pack finalScore
                        , "&platform=", TL.pack platform
                        , "&played=", if played then "on" else ""
                        , "&platinumed=", if platinumed then "on" else ""
                        , case maybeSource of Just s -> "&source=" <> TL.pack s; Nothing -> ""
                        ]

                [singleGame] ->  -- Um único jogo encontrado, redireciona para a página de confirmação com cover_url
                    redirect $ TL.concat
                        [ "/confirm?name=", TL.fromStrict (Igdb.grName singleGame)
                        , "&score=", TL.pack finalScore
                        , "&platform=", TL.pack platform
                        , "&cover_url=", maybe "" TL.fromStrict (Igdb.grCoverUrl singleGame)
                        , "&played=", if played then "on" else ""
                        , "&platinumed=", if platinumed then "on" else ""
                        , case maybeSource of Just s -> "&source=" <> TL.pack s; Nothing -> ""
                        ]

                multipleGames -> -- Múltiplos jogos encontrados, mostra a página de seleção
                    html $ renderText $ Selection.gameSelectionPage (T.pack name) (T.pack finalScore) (T.pack platform) played platinumed (fmap T.pack maybeSource) multipleGames
        _ -> html "Dados inválidos"

postEdit :: ActionM ()
postEdit = do
    gameId <- pathParam "id"
    requestBody <- body
    let formData = Format.parseFormData requestBody

    case (lookup "name" formData, lookup "platform" formData) of
        (Just name, Just platform) -> do
            let played = lookup "played" formData == Just "on"
            let score = lookup "score" formData
            let scoreDouble = if not played || score == Just "" || score == Just "0" then 0.0 else (read (maybe "0" id score) :: Double)
            let platinumed = played && lookup "platinumed" formData == Just "on"
            let maybeCoverUrl = case lookup "cover_url" formData of
                    Just "" -> Nothing
                    Just url -> Just (T.pack url)
                    Nothing -> Nothing

            -- Buscar gêneros e temas na API do IGDB antes de atualizar
            -- Usamos uma busca exata pelo nome para garantir os metadados corretos
            gameResults <- liftIO $ Igdb.searchMultipleGames (T.pack name)
            let (mGenres, mThemes) = case filter (\g -> T.toLower (Igdb.grName g) == T.toLower (T.pack name)) gameResults of
                    (g:_) -> (Just $ T.intercalate "," (Igdb.grGenres g), Just $ T.intercalate "," (Igdb.grThemes g))
                    _     -> case gameResults of
                               (g:_) -> (Just $ T.intercalate "," (Igdb.grGenres g), Just $ T.intercalate "," (Igdb.grThemes g))
                               _     -> (Nothing, Nothing)

            result <- liftIO $ DB.updateGame gameId (T.pack name) scoreDouble (T.pack platform) maybeCoverUrl played platinumed mGenres mThemes
            case result of
                Right _ -> do
                    isHtmx <- header "HX-Request"
                    case isHtmx of
                        Just "true" -> getBacklogWithFilters formData
                        _ -> do
                            referer <- header "Referer"
                            case referer of
                                Just ref -> redirect ref
                                Nothing -> redirect "/backlog"
                Left msg -> html $ TL.pack $ "Erro ao atualizar: " ++ msg
        _ -> html "Dados inválidos para edição"

postConfirm :: ActionM ()
postConfirm = do
    requestBody <- body
    let formData = Format.parseFormData requestBody
    mUserId <- Session.sessionLookup "user_id"

    case (mUserId, lookup "name" formData, lookup "platform" formData) of
        (Just userIdStr, Just name, Just platform) -> do
            let userId = read userIdStr :: Int
            let score = maybe "" id (lookup "score" formData)
            let scoreDouble = if score == "" || score == "0" then 0.0 else read score :: Double
            let played = lookup "played" formData == Just "on"
            let platinumed = lookup "platinumed" formData == Just "on"

            -- Pegar a cover_url do formulário
            let maybeCoverUrl = case lookup "cover_url" formData of
                    Just "" -> Nothing
                    Just url -> Just (T.pack url)
                    Nothing -> Nothing

            -- Buscar gêneros e temas na API do IGDB antes de inserir
            -- Tenta encontrar o jogo exato retornado pela busca para salvar os gêneros/temas corretos no banco
            gameResults <- liftIO $ Igdb.searchMultipleGames (T.pack name)
            let (mGenres, mThemes) = case filter (\g -> T.toLower (Igdb.grName g) == T.toLower (T.pack name)) gameResults of
                    (g:_) -> (Just $ T.intercalate "," (Igdb.grGenres g), Just $ T.intercalate "," (Igdb.grThemes g))
                    _     -> case gameResults of
                               (g:_) -> (Just $ T.intercalate "," (Igdb.grGenres g), Just $ T.intercalate "," (Igdb.grThemes g))
                               _     -> (Nothing, Nothing)

            result <- liftIO $ DB.insertGame userId (T.pack name) scoreDouble (T.pack platform) maybeCoverUrl played platinumed mGenres mThemes
            case result of
                Right _ -> case lookup "source" formData of
                               Just "recomend" -> redirect "/recomend"
                               _ -> case lookup "original_name" formData of
                                        Just origName -> redirect $ "/game-selection?name=" <> TL.pack origName <> "&score=&platform=PC"
                                        Nothing -> redirect "/add"
                Left msg -> html $ TL.pack $ "Erro ao salvar: " ++ msg
        _ -> html "Dados inválidos ou usuário não autenticado" -- Captura qualquer outro caso

postDelete :: ActionM ()
postDelete = do
    gameId <- pathParam "id"
    requestBody <- body
    let formData = Format.parseFormData requestBody
    liftIO $ DB.deleteGame gameId
    isHtmx <- header "HX-Request"
    case isHtmx of
        Just "true" -> getBacklogWithFilters formData
        _ -> do
            referer <- header "Referer"
            case referer of
                Just ref -> redirect ref
                Nothing -> redirect "/backlog"

getLogout :: ActionM ()
getLogout = do
    Session.sessionInsert "user_id" ""
    redirect "/"

getIndex :: ActionM ()
getIndex = html $ renderText Index.indexPage

getLogin :: ActionM ()
getLogin = html $ renderText Login.loginPage

getRegister :: ActionM ()
getRegister = html $ renderText Register.registerPage

getAdd :: ActionM ()
getAdd = do
    maybeNameParam <- queryParamMaybe "name" :: ActionM (Maybe TL.Text)
    let maybeName = case maybeNameParam of
            Just n -> Just (TL.toStrict n)
            Nothing -> Nothing
    maybeSourceParam <- queryParamMaybe "source" :: ActionM (Maybe TL.Text)
    let maybeSource = case maybeSourceParam of
            Just s -> Just (TL.toStrict s)
            Nothing -> Nothing
    html $ renderText $ AddGame.addGamePage maybeName maybeSource

getBacklog :: ActionM ()
getBacklog = do
    maybePlatform <- queryParamMaybe "platform" :: ActionM (Maybe TL.Text)
    maybeSort <- queryParamMaybe "sort" :: ActionM (Maybe TL.Text)
    maybeSearch <- queryParamMaybe "search" :: ActionM (Maybe TL.Text)
    maybeWantToPlayParam <- queryParamMaybe "want_to_play" :: ActionM (Maybe TL.Text)
    maybePlayedParam <- queryParamMaybe "played" :: ActionM (Maybe TL.Text)
    maybePlatinumedParam <- queryParamMaybe "platinumed" :: ActionM (Maybe TL.Text)

    let params = [ ("platform", maybe "" TL.toStrict maybePlatform)
                 , ("sort", maybe "" TL.toStrict maybeSort)
                 , ("search", maybe "" TL.toStrict maybeSearch)
                 , ("want_to_play", maybe "" TL.toStrict maybeWantToPlayParam)
                 , ("played", maybe "" TL.toStrict maybePlayedParam)
                 , ("platinumed", maybe "" TL.toStrict maybePlatinumedParam)
                 ]
    getBacklogWithFilters (map (\(k, v) -> (T.unpack k, T.unpack v)) params)

getBacklogWithFilters :: [(String, String)] -> ActionM ()
getBacklogWithFilters filters = do
    mUserId <- Session.sessionLookup "user_id"

    let platformFilter = T.pack $ maybe "" id (lookup "platform" filters)
    let searchFilter = T.pack $ maybe "" id (lookup "search" filters)
    let sortFilter = case lookup "sort" filters of
            Just "score" -> "score"
            Just "alpha" -> "alpha"
            _ -> "recent"

    let wantToPlayFilter = if lookup "want_to_play" filters == Just "on" then Just True else Nothing
    let playedFilter = if lookup "played" filters == Just "on" then Just True else Nothing
    let platinumedFilter = if lookup "platinumed" filters == Just "on" then Just True else Nothing

    case mUserId of
        Just userIdStr -> do
            let userId = read userIdStr :: Int
            allGames <- liftIO $ DB.getGames userId

            let filteredGames = Dt.filterGames allGames platformFilter searchFilter wantToPlayFilter playedFilter platinumedFilter

            let sortedGames = case sortFilter of
                                "score" -> sortBy (\a b -> compare (Game.score b) (Game.score a)) filteredGames
                                "recent" -> sortBy (\a b -> compare (Game.gameId b) (Game.gameId a)) filteredGames
                                _ -> sortBy (\a b -> compare (T.toLower $ Game.title a) (T.toLower $ Game.title b)) filteredGames

            html $ renderText $ Backlog.backlogPage searchFilter platformFilter sortFilter (wantToPlayFilter == Just True) (playedFilter == Just True) (platinumedFilter == Just True) sortedGames
        Nothing -> redirect "/login"

getConfirm :: ActionM ()
getConfirm = do
    name <- queryParam "name"
    score <- queryParam "score"
    platform <- queryParam "platform"

    maybePlayed <- queryParamMaybe "played" :: ActionM (Maybe TL.Text)
    maybePlatinumed <- queryParamMaybe "platinumed" :: ActionM (Maybe TL.Text)
    let played = maybePlayed == Just "on"
    let platinumed = maybePlatinumed == Just "on"

    -- Usar rescue para tratar o parâmetro opcional cover_url com anotação de tipo
    maybeCoverParam <- queryParamMaybe "cover_url" :: ActionM (Maybe TL.Text)

    let maybeCover = case maybeCoverParam of
            Just url | not (TL.null url) -> Just (TL.toStrict url)
            _ -> Nothing

    maybeSourceParam <- queryParamMaybe "source" :: ActionM (Maybe TL.Text)
    let maybeSource = case maybeSourceParam of
            Just s | not (TL.null s) -> Just (TL.toStrict s)
            _ -> Nothing

    html $ renderText $ Confirm.confirmPage (TL.toStrict name) (TL.toStrict score) (TL.toStrict platform) maybeCover played platinumed maybeSource

getGameSelection :: ActionM ()
getGameSelection = do
    name <- queryParam "name"
    score <- queryParam "score"
    platform <- queryParam "platform"

    maybePlayed <- queryParamMaybe "played" :: ActionM (Maybe TL.Text)
    maybePlatinumed <- queryParamMaybe "platinumed" :: ActionM (Maybe TL.Text)
    let played = maybePlayed == Just "on"
    let platinumed = maybePlatinumed == Just "on"

    maybeSourceParam <- queryParamMaybe "source" :: ActionM (Maybe TL.Text)
    let maybeSource = case maybeSourceParam of
            Just s | not (TL.null s) -> Just (TL.toStrict s)
            _ -> Nothing

    gameResults <- liftIO $ Igdb.searchMultipleGames (TL.toStrict name)
    html $ renderText $ Selection.gameSelectionPage (TL.toStrict name) (TL.toStrict score) (TL.toStrict platform) played platinumed maybeSource gameResults

getRecomend :: ActionM ()
getRecomend = do
    mUserId <- Session.sessionLookup "user_id"

    maybeMinYear <- queryParamMaybe "min_year" :: ActionM (Maybe TL.Text)
    maybeMaxYear <- queryParamMaybe "max_year" :: ActionM (Maybe TL.Text)

    let minYear = maybeMinYear >>= (readMaybe . TL.unpack)
    let maxYear = maybeMaxYear >>= (readMaybe . TL.unpack)

    case mUserId of
        Just userIdStr -> do
            let userId = read userIdStr :: Int
            allGames <- liftIO $ DB.getGames userId

            -- 1. Filtrar jogos que o usuário já jogou para extrair preferências, e dar nota base aos que quer jogar
            let processedGames = map (\g -> if Game.played g then g else g { Game.score = 7.5 }) allGames

            -- 2. Extrair estatísticas de gêneros e temas
            let genreStats = Recomend.processStats Game.genres processedGames
            let themeStats = Recomend.processStats Game.themes processedGames

            -- 3. Preparar critérios para a API com filtros de ano
            let criteria = Igdb.RecommendationCriteria genreStats themeStats minYear maxYear

            -- 4. Lista de títulos para excluir (já jogados, no backlog, ou ignorados)
            ignoredTitles <- liftIO $ DB.getIgnoredRecommendations userId
            let excludeTitles = map Game.title allGames ++ ignoredTitles

            -- 5. Buscar na API do IGDB
            (trending, topRated, recommended) <- liftIO $ Igdb.searchRecommendations criteria excludeTitles

            html $ renderText $ Recomend.recomendPage trending topRated recommended minYear maxYear
        Nothing -> redirect "/login"

postRecomend :: ActionM ()
postRecomend = redirect "/recomend"

getMigrateMetadata :: ActionM ()
getMigrateMetadata = do
    mUserId <- Session.sessionLookup "user_id"
    case mUserId of
        Just userIdStr -> do
            let userId = read userIdStr :: Int
            allGames <- liftIO $ DB.getGames userId

            -- Filtra apenas os jogos que não possuem gêneros ou temas preenchidos
            let gamesToUpdate = filter (\g -> Game.genres g == Nothing || Game.themes g == Nothing) allGames

            liftIO $ putStrLn $ "Iniciando migração para " ++ show (length gamesToUpdate) ++ " jogos do usuário " ++ userIdStr

            -- Processa cada jogo buscando na API e atualizando o banco
            liftIO $ mapM_ (updateSingleGame userId) gamesToUpdate

            redirect "/recomend"
        Nothing -> redirect "/login"
  where
    updateSingleGame userId g = do
        putStrLn $ "Migrando: " ++ T.unpack (Game.title g)
        gameResults <- Igdb.searchMultipleGames (Game.title g)
        -- Tenta encontrar o match exato ou pega o primeiro resultado
        let maybeResult = case filter (\r -> T.toLower (Igdb.grName r) == T.toLower (Game.title g)) gameResults of
                (res:_) -> Just res
                [] -> case gameResults of
                    (res:_) -> Just res
                    [] -> Nothing

        case maybeResult of
            Just res -> do
                let gList = Just $ T.intercalate "," (Igdb.grGenres res)
                    tList = Just $ T.intercalate "," (Igdb.grThemes res)
                _ <- DB.updateGame (Game.gameId g) (Game.title g) (Game.score g) (Game.platform g) (Game.cover_url g) (Game.played g) (Game.platinumed g) gList tList
                putStrLn $ "Sucesso: " ++ T.unpack (Game.title g)
            Nothing -> putStrLn $ "Não encontrado na API: " ++ T.unpack (Game.title g)

postIgnoreRecomend :: ActionM ()
postIgnoreRecomend = do
    requestBody <- body
    let formData = Format.parseFormData requestBody
    mUserId <- Session.sessionLookup "user_id"

    case (mUserId, lookup "title" formData) of
        (Just userIdStr, Just title) -> do
            let userId = read userIdStr :: Int
            liftIO $ DB.ignoreRecommendation userId (T.pack title)

            referer <- header "Referer"
            case referer of
                Just ref -> redirect ref
                Nothing -> redirect "/recomend"
        _ -> redirect "/recomend"

getTournament :: ActionM ()
getTournament = do
    mUserId <- Session.sessionLookup "user_id"
    case mUserId of
        Just userIdStr -> do
            let userId = read userIdStr :: Int
            allGames <- liftIO $ DB.getGames userId
            let backlogGames = filter (not . Game.played) allGames
            shuffledGames <- liftIO $ Igdb.shuffleList backlogGames
            html $ renderText $ Tournament.tournamentPage shuffledGames
        Nothing -> redirect "/login"

postTournamentStart :: ActionM ()
postTournamentStart = do
    requestBody <- body
    let formData = Format.parseFormData requestBody
    let gameIds = map (read . snd) $ filter (\(k, _) -> k == "game_ids") formData :: [Int]

    mUserId <- Session.sessionLookup "user_id"
    case mUserId of
        Just userIdStr -> do
            let userId = read userIdStr :: Int
            allGames <- liftIO $ DB.getGames userId
            let selectedGamesRaw = filter (\g -> Game.gameId g `elem` gameIds) allGames
            selectedGames <- liftIO $ Igdb.shuffleList selectedGamesRaw

            if length selectedGames < 2
                then html "Selecione pelo menos 2 jogos."
                else do
                    let (g1:g2:rest) = selectedGames
                    let restIds = map Game.gameId rest
                    let total = length selectedGames
                    html $ renderText $ Tournament.battleView g1 g2 restIds total
        Nothing -> html "Não autenticado"

postTournamentVote :: ActionM ()
postTournamentVote = do
    requestBody <- body
    let formData = Format.parseFormData requestBody
    let winnerId = read $ maybe "0" id (lookup "winner_id" formData) :: Int
    -- O HTMX não envia o estado anterior facilmente a menos que incluamos,
    -- mas podemos usar hx-vals para passar o que sobrou.
    -- Para simplificar esta versão, vamos buscar os IDs restantes de um campo que adicionaremos.

    -- Nota: Para manter o estado entre cliques HTMX sem sessão complexa,
    -- vamos extrair os IDs que ainda não lutaram do formulário.
    let remainingIdsStr = maybe "" T.pack (lookup "remaining_ids" formData)
    let total = read $ maybe "2" id (lookup "total_count" formData) :: Int

    mUserId <- Session.sessionLookup "user_id"
    case mUserId of
        Just userIdStr -> do
            let userId = read userIdStr :: Int
            allGames <- liftIO $ DB.getGames userId

            let winner = head $ filter (\g -> Game.gameId g == winnerId) allGames
            let remainingIds = if T.null remainingIdsStr then [] else map (read . T.unpack) (T.splitOn "," remainingIdsStr) :: [Int]
            let remainingGames = filter (\g -> Game.gameId g `elem` remainingIds) allGames

            case remainingGames of
                [] -> html $ renderText $ Tournament.winnerView winner
                (next:rest) -> do
                    let restIds = map Game.gameId rest
                    html $ renderText $ Tournament.battleView winner next restIds total
        Nothing -> html "Não autenticado"
