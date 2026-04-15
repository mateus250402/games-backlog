import re

# Update Handles.hs
with open("app/Utils/Handles.hs", "r") as f:
    h_content = f.read()

h_content = h_content.replace(
    'sortBy ( b -> compare (Game.score b) (Game.score a))',
    'sortBy (\\a b -> compare (Game.score b) (Game.score a))'
)
h_content = h_content.replace(
    'sortBy ( b -> compare (Game.id b) (Game.id a))',
    'sortBy (\\a b -> compare (Game.id b) (Game.id a))'
)
h_content = h_content.replace(
    'sortBy ( b -> compare (T.toLower $ Game.title a) (T.toLower $ Game.title b))',
    'sortBy (\\a b -> compare (T.toLower $ Game.title a) (T.toLower $ Game.title b))'
)

with open("app/Utils/Handles.hs", "w") as f:
    f.write(h_content)

# Update Backlog.hs
with open("app/Pages/Backlog.hs", "r") as f:
    b_content = f.read()

b_content = b_content.replace(
    'backlogPage :: Text -> Text -> Bool -> Bool -> Bool -> [Game] -> Html ()',
    'backlogPage :: Text -> Text -> Text -> Bool -> Bool -> [Game] -> Html ()'
)

b_content = b_content.replace(
    'backlogPage searchFilter platformFilter sortByScore wantToPlayFilter platinumedFilter games = html_ $ do',
    'backlogPage searchFilter platformFilter sortFilter wantToPlayFilter platinumedFilter games = html_ $ do'
)

options_old = '''select_ [name_ "sort", class_ "form-select w-auto"] $ do
                    option_ ([value_ ""] ++ if not sortByScore then [selected_ ""] else []) "Sem ordenação"
                    option_ ([value_ "score"] ++ if sortByScore then [selected_ ""] else []) "Ordenar por nota"'''

options_new = '''select_ [name_ "sort", class_ "form-select w-auto"] $ do
                    option_ ([value_ "alpha"] ++ if sortFilter == "alpha" then [selected_ ""] else []) "Ordem Alfabética"
                    option_ ([value_ "recent"] ++ if sortFilter == "recent" then [selected_ ""] else []) "Mais Recentes"
                    option_ ([value_ "score"] ++ if sortFilter == "score" then [selected_ ""] else []) "Ordenar por Nota"'''

b_content = b_content.replace(options_old, options_new)

with open("app/Pages/Backlog.hs", "w") as f:
    f.write(b_content)

