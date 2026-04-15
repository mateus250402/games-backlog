with open("app/Api/Igdb.hs", "r") as f:
    text = f.read()

remove_accents = '''
-- Função para remover acentos antes de consultar a API
removeAccents :: T.Text -> T.Text
removeAccents = T.map replaceChar
  where
    replaceChar c
      | c `elem` ("áàãâä" :: String) = 'a'
      | c `elem` ("ÁÀÃÂÄ" :: String) = 'A'
      | c `elem` ("éèêë" :: String)  = 'e'
      | c `elem` ("ÉÈÊË" :: String)  = 'E'
      | c `elem` ("íìîï" :: String)  = 'i'
      | c `elem` ("ÍÌÎÏ" :: String)  = 'I'
      | c `elem` ("óòõôö" :: String) = 'o'
      | c `elem` ("ÓÒÕÔÖ" :: String) = 'O'
      | c `elem` ("úùûü" :: String)  = 'u'
      | c `elem` ("ÚÙÛÜ" :: String)  = 'U'
      | c `elem` ("ç" :: String)     = 'c'
      | c `elem` ("Ç" :: String)     = 'C'
      | c `elem` ("ñ" :: String)     = 'n'
      | c `elem` ("Ñ" :: String)     = 'N'
      | otherwise                    = c

'''

text = text.replace('searchMultipleGames :: T.Text -> IO [GameResult]\nsearchMultipleGames gameName = do',
                    remove_accents + 'searchMultipleGames :: T.Text -> IO [GameResult]\nsearchMultipleGames gameName = do\n    let cleanName = removeAccents gameName')

text = text.replace('search \\"" <> T.unpack gameName <> "\\"; limit 20;"',
                    'search \\"" <> T.unpack cleanName <> "\\"; limit 20;"')

with open("app/Api/Igdb.hs", "w") as f:
    f.write(text)
