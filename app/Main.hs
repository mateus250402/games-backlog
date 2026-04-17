{-# LANGUAGE OverloadedStrings #-}

module Main where

import Web.Scotty (scotty, get, post)

-- Utils
import qualified DB.DB as DB
import qualified Utils.Session as Session
import qualified Utils.Handles as Hd

main :: IO ()
main = do
    DB.initDB

    scotty 3000 $ do

        get "/" Hd.getIndex

        get "/login" Hd.getLogin
        post "/login" Hd.postLogin

        get "/logout" Hd.getLogout

        get "/register" Hd.getRegister
        post "/register" Hd.postRegister

        get "/add" $ Session.requireAuth $ do Hd.getAdd
        post "/add" $ Session.requireAuth $ do Hd.postAdd

        get "/backlog" $ Session.requireAuth $ do Hd.getBacklog

        get "/game-selection" $ Session.requireAuth $ do Hd.getGameSelection

        get "/confirm" $ Session.requireAuth $ do Hd.getConfirm
        post "/confirm" $ Session.requireAuth $ do Hd.postConfirm

        post "/edit/:id" $ Session.requireAuth $ do Hd.postEdit

        post "/delete/:id" $ Session.requireAuth $ do Hd.postDelete

        get "/tournament" $ Session.requireAuth $ do Hd.getTournament
        post "/tournament/start" $ Session.requireAuth $ do Hd.postTournamentStart
        post "/tournament/vote" $ Session.requireAuth $ do Hd.postTournamentVote

        get "/recomend" $ Session.requireAuth $ do Hd.getRecomend
        post "/recomend" $ Session.requireAuth $ do Hd.postRecomend
        post "/ignore-recomend" $ Session.requireAuth $ do Hd.postIgnoreRecomend

        get "/migrate-metadata" $ Session.requireAuth $ do Hd.getMigrateMetadata
