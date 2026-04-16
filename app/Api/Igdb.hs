{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Api.Igdb where

import Network.HTTP.Simple
import Data.Aeson
import Data.Aeson.Types (Parser, parseEither)
import Data.List (sortBy, sortOn)
import System.Random (randomRIO)
import qualified Data.Text as T
import qualified Data.ByteString.Lazy.Char8 as LBS
import Data.Maybe (mapMaybe)
import Utils.Format as Format

data GameResult = GameResult
    { grName :: T.Text
    , grPlatforms :: [T.Text]
    , grYear :: Maybe Int
    , grCoverUrl :: Maybe T.Text
    , grGenres :: [T.Text]
    , grThemes :: [T.Text]
    } deriving (Show, Eq)

data RecommendationCriteria = RecommendationCriteria
    { rcGenres :: [(T.Text, Int, Double)] -- (Nome, Quantidade, Soma Notas)
    , rcThemes :: [(T.Text, Int, Double)] -- (Nome, Quantidade, Soma Notas)
    , rcMinYear :: Maybe Int
    , rcMaxYear :: Maybe Int
    } deriving (Show, Eq)

searchMultipleGames :: T.Text -> IO [GameResult]
searchMultipleGames gameName = do
    let cleanName = Format.removeAccents gameName
    let token = "ow6kyy3nm5a51hud2b940pu4nupcb5"
    let query = "fields name, platforms.name, first_release_date, cover.url, genres.name, themes.name; search \"" <> T.unpack cleanName <> "\"; limit 20;"

    request' <- parseRequest "https://api.igdb.com/v4/games"
    let request = setRequestMethod "POST"
                $ setRequestHeader "Client-ID" ["poa6s33d3kywrcalk2xa52cs4h2bu2"]
                $ setRequestHeader "Authorization" ["Bearer " <> token]
                $ setRequestHeader "Content-Type" ["text/plain"]
                $ setRequestBodyLBS (LBS.pack query)
                $ request'

    response <- httpLBS request
    let responseBody = getResponseBody response

    case eitherDecode responseBody :: Either String [Value] of
        Left _ -> return []
        Right games -> return $ mapMaybe parseGameResultSafe games

parseGameResultSafe :: Value -> Maybe GameResult
parseGameResultSafe value =
    case parseEither parseGameResult value of
        Left _ -> Nothing
        Right result -> Just result

parseGameResult :: Value -> Parser GameResult
parseGameResult = withObject "Game" $ \obj -> do
    name <- obj .: "name"
    platforms <- obj .:? "platforms" .!= []
    platformNames <- mapM (\p -> withObject "Platform" (.: "name") p) platforms

    genres <- obj .:? "genres" .!= []
    genreNames <- mapM (\g -> withObject "Genre" (.: "name") g) genres

    themes <- obj .:? "themes" .!= []
    themeNames <- mapM (\t -> withObject "Theme" (.: "name") t) themes

    releaseDate <- obj .:? "first_release_date"
    let year = case releaseDate of
            Nothing -> Nothing
            Just timestamp -> Just $ Format.timestampToYear timestamp

    cover <- obj .:? "cover"
    coverUrl <- case cover of
        Nothing -> return Nothing
        Just coverObj -> do
            url <- withObject "Cover" (.: "url") coverObj
            let bigUrl = T.replace "t_thumb" "t_cover_big" url
            return $ Just $ "https:" <> bigUrl

    return $ GameResult name platformNames year coverUrl genreNames themeNames

searchRecommendations :: RecommendationCriteria -> [T.Text] -> IO ([GameResult], [GameResult], [GameResult])
searchRecommendations criteria excludeTitles = do
    let token = "ow6kyy3nm5a51hud2b940pu4nupcb5"

    -- Pega apenas o Top 5 para focar nos gostos mais fortes do usuário
    let rankedGenres = take 5 $ rankByPreference (rcGenres criteria)
    let rankedThemes = take 5 $ rankByPreference (rcThemes criteria)

    -- Mapeamento de nomes do IGDB para IDs numéricos (conforme documentação IGDB v4)
    let genreMap =
          [ ("Point-and-click", "2"), ("Fighting", "4"), ("Shooter", "5"), ("Music", "7")
          , ("Platform", "8"), ("Puzzle", "9"), ("Racing", "10"), ("Real Time Strategy (RTS)", "11")
          , ("Role-playing (RPG)", "12"), ("Simulator", "13"), ("Sport", "14"), ("Strategy", "15")
          , ("Turn-based strategy (TBS)", "16"), ("Tactical", "24"), ("Hack and slash/Beat 'em up", "25")
          , ("Quiz/Trivia", "26"), ("Pinball", "30"), ("Adventure", "31"), ("Indie", "32")
          , ("Arcade", "33"), ("Visual Novel", "34"), ("Card & Board Game", "35"), ("MOBA", "36")
          ]

    let themeMap =
          [ ("Fantasy", "17"), ("Science fiction", "18"), ("Horror", "19")
          , ("Survival", "21"), ("Historical", "22"), ("Stealth", "27"), ("Comedy", "20")
          , ("Business", "23"), ("Drama", "31"), ("Non-fiction", "32"), ("Sandbox", "33")
          , ("Educational", "34"), ("Kids", "35"), ("Open world", "38"), ("Warfare", "39")
          , ("Party", "40"), ("4X (explore, expand, exploit, and exterminate)", "41"), ("Mystery", "43")
          , ("Erotic", "42")
          ]

    let getIds mapping names = mapMaybe (\n -> lookup n mapping) names
    let topGenreIds = getIds genreMap (map fst rankedGenres)
    let topThemeIds = getIds themeMap (map fst rankedThemes)

    -- Monta filtro OR combinando os IDs extraídos, permitindo flexibilidade se um dos lados falhar
    let prefFilter = case (not $ null topGenreIds, not $ null topThemeIds) of
            (True, True)   -> " & (genres = (" <> T.unpack (T.intercalate "," topGenreIds) <> ") | themes = (" <> T.unpack (T.intercalate "," topThemeIds) <> "))"
            (True, False)  -> " & genres = (" <> T.unpack (T.intercalate "," topGenreIds) <> ")"
            (False, True)  -> " & themes = (" <> T.unpack (T.intercalate "," topThemeIds) <> ")"
            (False, False) -> ""

    let minDateFilter = case rcMinYear criteria of
            Just y -> " & first_release_date >= " <> show (mkTimestamp y)
            Nothing -> " & first_release_date >= 1104537600" -- Default 2005
    let maxDateFilter = case rcMaxYear criteria of
            Just y -> " & first_release_date <= " <> show (mkTimestamp y + 31535999)
            Nothing -> ""

    let query = "fields name, platforms.name, first_release_date, cover.url, genres.name, themes.name; "
             <> "where total_rating >= 70 & total_rating_count > 25"
             <> prefFilter <> minDateFilter <> maxDateFilter
             <> "; limit 500; sort total_rating desc;"

    let trendingQuery = "fields name, platforms.name, first_release_date, cover.url, genres.name, themes.name; "
                     <> "where first_release_date > 1640995200 & total_rating_count > 10" -- After Jan 1, 2022
                     <> minDateFilter <> maxDateFilter
                     <> "; limit 100; sort total_rating_count desc;"

    let topRatedQuery = "fields name, platforms.name, first_release_date, cover.url, genres.name, themes.name; "
                     <> "where rating >= 85 & rating_count > 100"
                     <> minDateFilter <> maxDateFilter
                     <> "; limit 100; sort rating desc;"

    request' <- parseRequest "https://api.igdb.com/v4/games"
    let mkReq q = setRequestMethod "POST"
                $ setRequestHeader "Client-ID" ["poa6s33d3kywrcalk2xa52cs4h2bu2"]
                $ setRequestHeader "Authorization" ["Bearer " <> token]
                $ setRequestHeader "Content-Type" ["text/plain"]
                $ setRequestBodyLBS (LBS.pack q)
                $ request'

    responsePref <- httpLBS (mkReq query)
    responseTrending <- httpLBS (mkReq trendingQuery)
    responseTopRated <- httpLBS (mkReq topRatedQuery)

    let parseBody body = case eitherDecode body :: Either String [Value] of
            Left _ -> []
            Right games -> mapMaybe parseGameResultSafe games

    let prefResults = parseBody (getResponseBody responsePref)
    let trendingResults = parseBody (getResponseBody responseTrending)
    let topRatedResults = parseBody (getResponseBody responseTopRated)

    let filteredPref = filter (\g -> isNewGame excludeTitles g && not (isAndroidOnly g)) prefResults
    let filteredTrending = filter (\g -> isNewGame excludeTitles g && not (isAndroidOnly g)) trendingResults
    let filteredTopRated = filter (\g -> isNewGame excludeTitles g && not (isAndroidOnly g)) topRatedResults

    putStrLn $ "DEBUG: Preferências do usuário - Gêneros: " ++ show (map fst rankedGenres)
    putStrLn $ "DEBUG: Preferências do usuário - Temas: " ++ show (map fst rankedThemes)

    let scored = if null rankedGenres && null rankedThemes
                 then map (\g -> (0.0, g)) filteredPref
                 else map (\g ->
                    let s = calculateMatchScore g rankedGenres rankedThemes
                    in (s, g)) filteredPref

    -- Ordena por score descendente; como 'sortBy' é estável, mantém a ordem original da API (total_rating desc) em caso de empate
    let sortedByMatch = sortBy (\(s1, _) (s2, _) -> compare s2 s1) scored

    let topScores = take 3 sortedByMatch
    mapM_ (\(s, g) -> putStrLn $ "DEBUG: Match Score [" ++ T.unpack (grName g) ++ "]: " ++ show s) topScores

    -- Recomendados baseados no gosto
    let top20Match = take 30 $ map snd sortedByMatch
    shuffledMatch <- shuffleList top20Match
    let recommendedFinal = take 21 shuffledMatch

    -- Trending (Populares recentes)
    shuffledTrending <- shuffleList filteredTrending
    let trendingFinal = take 9 shuffledTrending

    -- Aclamados (Top Rated)
    shuffledTopRated <- shuffleList filteredTopRated
    let topRatedFinal = take 9 shuffledTopRated

    return (trendingFinal, topRatedFinal, recommendedFinal)
  where
    calculateMatchScore :: GameResult -> [(T.Text, Double)] -> [(T.Text, Double)] -> Double
    calculateMatchScore game genreWeights themeWeights =
        let safeEq a b = T.toLower (T.strip a) == T.toLower (T.strip b)
            gScore = sum [w | g <- grGenres game, (name, w) <- genreWeights, safeEq g name]
            tScore = sum [w | t <- grThemes game, (name, w) <- themeWeights, safeEq t name]
        in gScore + tScore

    mkTimestamp :: Int -> Int
    mkTimestamp year = (year - 1970) * 31536000 + 86400

    rankByPreference :: [(T.Text, Int, Double)] -> [(T.Text, Double)]
    rankByPreference stats =
        let scored = map (\(name, count, sumScore) ->
                let avg = if count > 0 then sumScore / fromIntegral count else 0
                    volumeScore = logBase 2 (fromIntegral count + 1) * 3.0
                    baseWeight = volumeScore + (avg * 1.2)
                    -- Ignora completamente o gênero/tema "Action" (Ação) para não poluir as recomendações
                    weight = if T.toLower (T.strip name) == "action" then 0.0 else baseWeight
                in (name, weight)) stats
        in reverse $ sortOn snd scored

    isAndroidOnly :: GameResult -> Bool
    isAndroidOnly g =
        let plats = map T.toLower (grPlatforms g)
        in not (null plats) && all (== "android") plats

    isNewGame :: [T.Text] -> GameResult -> Bool
    isNewGame ownedTitles rec =
        let recName = T.toLower (grName rec)
            blacklist = [" dlc", " bundle", " expansion", " season pass", " soundtrack", " artbook", " skin pack", " pass ", " pack"]
            isSecondaryContent = any (`T.isInfixOf` recName) blacklist
            cleanName name =
                let n = T.toLower name
                    n' = T.replace ": wild hunt" "" $ T.replace "wild hunt" "" n
                in T.strip $
                   T.replace " edition" "" $ T.replace " definitive" "" $
                   T.replace " remastered" "" $ T.replace " remaster" "" $
                   T.replace " anthology" "" $ T.replace " special" "" $
                   T.replace " deluxe" "" $ T.replace " gold" "" $
                   T.replace " complete" "" $ T.replace " game of the year" "" $
                   T.replace " - " " " $ T.replace ":" "" $
                   T.replace " goty" "" n'
            recBase = cleanName recName
            alreadyOwned = any (\owned ->
                let ownedLower = T.toLower owned
                    ownedBase = cleanName ownedLower
                in recName == ownedLower
                   || (T.length recBase > 5 && recBase == ownedBase)
                   || (T.length ownedBase > 5 && T.isInfixOf ownedBase recBase)
                   || (T.length recBase > 5 && T.isInfixOf recBase ownedBase)
               ) ownedTitles
        in not isSecondaryContent && not alreadyOwned

    shuffleList [] = return []
    shuffleList xs = do
        randomized <- mapM (\x -> do { r <- randomRIO (0, 100000 :: Int); return (r, x) }) xs
        return $ map snd $ sortOn fst randomized
