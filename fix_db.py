with open("app/DB/DB.hs", "r") as f:
    text = f.read()

text = text.replace(
    'rows <- query conn "SELECT title FROM ignored_recommendations WHERE user_id = ?" (Only userId) :: IO [[Text]]\n    close conn\n    return $ map head rows',
    'rows <- query conn "SELECT title FROM ignored_recommendations WHERE user_id = ?" (Only userId) :: IO [Only Text]\n    close conn\n    return $ map fromOnly rows'
)

with open("app/DB/DB.hs", "w") as f:
    f.write(text)
