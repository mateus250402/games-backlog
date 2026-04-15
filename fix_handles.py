import re

with open("app/Utils/Handles.hs", "r") as f:
    text = f.read()

# Add postIgnoreRecomend
ignore_func = '''
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
'''
text += ignore_func

# Update getRecomend to exclude ignored games
get_rec_old = '''            -- 4. Lista de títulos para excluir (já jogados ou no backlog)
            let excludeTitles = map Game.title allGames

            -- 5. Buscar na API do IGDB
            recommended <- liftIO $ Igdb.searchRecommendations criteria excludeTitles'''

get_rec_new = '''            -- 4. Lista de títulos para excluir (já jogados, no backlog, ou ignorados)
            ignoredTitles <- liftIO $ DB.getIgnoredRecommendations userId
            let excludeTitles = map Game.title allGames ++ ignoredTitles

            -- 5. Buscar na API do IGDB
            recommended <- liftIO $ Igdb.searchRecommendations criteria excludeTitles'''

text = text.replace(get_rec_old, get_rec_new)

with open("app/Utils/Handles.hs", "w") as f:
    f.write(text)
