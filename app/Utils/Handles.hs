{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# OPTIONS_GHC -Wno-deprecations #-}

module Utils.Handles where

import Web.Scotty (ActionM, body, html, redirect, pathParam, queryParam, queryParamMaybe)
import qualified Data.Text as T
import qualified Data.Text.Lazy as TL
import Control.Monad.IO.Class (liftIO)
import Data.List (sortBy)
import Lucid (renderText)
import Control.Exception (SomeException)

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
                        ]

                [singleGame] ->  -- Um único jogo encontrado, redireciona para a página de confirmação com cover_url
                    redirect $ TL.concat
                        [ "/confirm?name=", TL.fromStrict (Igdb.grName singleGame)
                        , "&score=", TL.pack finalScore
                        , "&platform=", TL.pack platform
                        , "&cover_url=", maybe "" TL.fromStrict (Igdb.grCoverUrl singleGame)
                        , "&played=", if played then "on" else ""
                        , "&platinumed=", if platinumed then "on" else ""
                        ]

                multipleGames -> -- Múltiplos jogos encontrados, mostra a página de seleção
                    html $ renderText $ Selection.gameSelectionPage (T.pack name) (T.pack finalScore) (T.pack platform) played platinumed multipleGames
        _ -> html "Dados inválidos"

postConfirm :: ActionM ()
postConfirm = do
    requestBody <- body
    let formData = Format.parseFormData requestBody
    mUserId <- Session.sessionLookup "user_id"

    case (mUserId, lookup "name" formData, lookup "score" formData, lookup "platform" formData) of
        (Just userIdStr, Just name, Just score, Just platform) -> do
            let userId = read userIdStr :: Int
            let scoreDouble = if score == "" || score == "0" then 0.0 else read score :: Double
            let played = lookup "played" formData == Just "on"
            let platinumed = lookup "platinumed" formData == Just "on"

            -- Pegar a cover_url do formulário
            let maybeCoverUrl = case lookup "cover_url" formData of
                    Just "" -> Nothing
                    Just url -> Just (T.pack url)
                    Nothing -> Nothing

            result <- liftIO $ DB.insertGame userId (T.pack name) scoreDouble (T.pack platform) maybeCoverUrl played platinumed
            case result of
                Right _ -> redirect "/add"
                Left msg -> html $ TL.pack $ "Erro ao salvar: " ++ msg
        _ -> html "Dados inválidos ou usuário não autenticado" -- Captura qualquer outro caso

postDelete :: ActionM ()
postDelete = do
    gameId <- pathParam "id"
    liftIO $ DB.deleteGame gameId
    redirect "/backlog"

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
getAdd = html $ renderText AddGame.addGamePage

getBacklog :: ActionM ()
getBacklog = do
    mUserId <- Session.sessionLookup "user_id"

    -- Usar rescue para tratar parâmetros opcionais com anotações de tipo
    maybePlatform <- queryParamMaybe "platform" :: ActionM (Maybe TL.Text)
    maybeSort <- queryParamMaybe "sort" :: ActionM (Maybe TL.Text)
    maybeSearch <- queryParamMaybe "search" :: ActionM (Maybe TL.Text)

    let platformFilter = case maybePlatform of
            Nothing -> ""
            Just p -> TL.toStrict p

    let searchFilter = case maybeSearch of
            Nothing -> ""
            Just s -> TL.toStrict s

    let sortByScore = case maybeSort of
            Just "score" -> True
            _ -> False

    case mUserId of
        Just userIdStr -> do
            let userId = read userIdStr :: Int
            allGames <- liftIO $ DB.getGames userId

            let filteredGames = Dt.filterGames allGames platformFilter searchFilter

            let sortedGames = if sortByScore
                                then sortBy (\a b -> compare (Game.score b) (Game.score a)) filteredGames
                                else filteredGames

            html $ renderText $ Backlog.backlogPage sortedGames
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

    html $ renderText $ Confirm.confirmPage (TL.toStrict name) (TL.toStrict score) (TL.toStrict platform) maybeCover played platinumed

getGameSelection :: ActionM ()
getGameSelection = do
    name <- queryParam "name"
    score <- queryParam "score"
    platform <- queryParam "platform"

    maybePlayed <- queryParamMaybe "played" :: ActionM (Maybe TL.Text)
    maybePlatinumed <- queryParamMaybe "platinumed" :: ActionM (Maybe TL.Text)
    let played = maybePlayed == Just "on"
    let platinumed = maybePlatinumed == Just "on"

    gameResults <- liftIO $ Igdb.searchMultipleGames (TL.toStrict name)
    html $ renderText $ Selection.gameSelectionPage (TL.toStrict name) (TL.toStrict score) (TL.toStrict platform) played platinumed gameResults
