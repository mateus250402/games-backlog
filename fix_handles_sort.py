import re

with open("app/Utils/Handles.hs", "r") as f:
    content = f.read()

# Replace sortByScore with sortFilter
content = re.sub(
    r'let sortByScore = case maybeSort of\n            Just "score" -> True\n            _ -> False',
    r'''let sortFilter = case maybeSort of
            Just "score" -> "score"
            Just "recent" -> "recent"
            _ -> "alpha"''',
    content
)

# Update backlogPage call to use sortFilter
content = re.sub(
    r'let sortedGames = if sortByScore\n                                then sortBy \(\\a b -> compare \(Game\.score b\) \(Game\.score a\)\) filteredGames\n                                else filteredGames\n\n            html \$ renderText \$ Backlog\.backlogPage searchFilter platformFilter sortByScore \(wantToPlayFilter == Just True\) \(platinumedFilter == Just True\) sortedGames',
    r'''let sortedGames = case sortFilter of
                                "score" -> sortBy (\a b -> compare (Game.score b) (Game.score a)) filteredGames
                                "recent" -> sortBy (\a b -> compare (Game.id b) (Game.id a)) filteredGames
                                _ -> sortBy (\a b -> compare (T.toLower $ Game.title a) (T.toLower $ Game.title b)) filteredGames

            html $ renderText $ Backlog.backlogPage searchFilter platformFilter sortFilter (wantToPlayFilter == Just True) (platinumedFilter == Just True) sortedGames''',
    content
)

with open("app/Utils/Handles.hs", "w") as f:
    f.write(content)
