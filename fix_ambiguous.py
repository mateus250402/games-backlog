with open("app/Api/Igdb.hs", "r") as f:
    text = f.read()

text = text.replace(
'''
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

''', '')

text = text.replace('removeAccents gameName', 'Format.removeAccents gameName')

with open("app/Api/Igdb.hs", "w") as f:
    f.write(text)

