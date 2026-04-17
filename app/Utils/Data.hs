{-# LANGUAGE OverloadedStrings #-}

module Utils.Data where

import qualified Data.Text as T
import Models.Games (Game(..))

-- Filtra a lista de jogos com base nos critérios de plataforma, termo de busca, status de "Quero Jogar", "Jogado" e "Platinado"
filterGames :: [Game] -> T.Text -> T.Text -> Maybe Bool -> Maybe Bool -> Maybe Bool -> [Game]
filterGames games platformFilter searchFilter maybeWantToPlay maybePlayed maybePlatinumed =
    let -- Filtro por plataforma
        platformFiltered = if T.null platformFilter
                            then games
                            else filter (\game -> platform game == platformFilter) games

        -- Filtro por título (busca textual)
        searchFiltered = if T.null searchFilter
                         then platformFiltered
                         else filter (\game -> T.toLower searchFilter `T.isInfixOf` T.toLower (title game)) platformFiltered

        -- Filtro por status "Quero Jogar" (se especificado, busca jogos não jogados)
        wtpFiltered = case maybeWantToPlay of
                            Nothing -> searchFiltered
                            Just wtp -> if wtp
                                        then filter (\game -> not (played game)) searchFiltered
                                        else searchFiltered

        -- Filtro por status "Jogado" (se especificado)
        playedFiltered = case maybePlayed of
                            Nothing -> wtpFiltered
                            Just p -> filter (\game -> played game == p) wtpFiltered

        -- Filtro por status "Platinado" (se especificado)
        platinumedFiltered = case maybePlatinumed of
                                Nothing -> playedFiltered
                                Just pt -> filter (\game -> platinumed game == pt) playedFiltered

    in platinumedFiltered
