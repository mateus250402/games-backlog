{-# LANGUAGE OverloadedStrings #-}
import qualified Data.Text as T

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

main = do
    print $ removeAccents "Pokémon Super Mario Bros. Ação Coração"
