import re

with open("app/DB/DB.hs", "r") as f:
    text = f.read()

# Add to initDB
init_query = '''    execute_ conn $ Query $ T.pack $ unlines
        [ "CREATE TABLE IF NOT EXISTS ignored_recommendations ("
        , "  id INTEGER PRIMARY KEY AUTOINCREMENT,"
        , "  user_id INTEGER NOT NULL,"
        , "  title TEXT NOT NULL,"
        , "  FOREIGN KEY (user_id) REFERENCES users (id)"
        , ")"
        ]

    close conn'''
text = text.replace('    close conn\n\n-- Função para hashear a senha', init_query + '\n\n-- Função para hashear a senha')

# Add functions
new_funcs = '''
ignoreRecommendation :: Int -> Text -> IO ()
ignoreRecommendation userId title = do
    conn <- connectDB
    execute conn "INSERT INTO ignored_recommendations (user_id, title) VALUES (?, ?)" (userId, title)
    close conn

getIgnoredRecommendations :: Int -> IO [Text]
getIgnoredRecommendations userId = do
    conn <- connectDB
    rows <- query conn "SELECT title FROM ignored_recommendations WHERE user_id = ?" (Only userId) :: IO [[Text]]
    close conn
    return $ map head rows
'''
text += new_funcs

with open("app/DB/DB.hs", "w") as f:
    f.write(text)
