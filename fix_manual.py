with open("app/Utils/Handles.hs", "r") as f:
    lines = f.readlines()

with open("app/Utils/Handles.hs", "w") as f:
    for line in lines:
        if "sortedGames = case sortFilter of" in line:
            f.write(line)
        elif '-> sortBy ( b -> compare (Game.score b) (Game.score a)) filteredGames' in line:
            f.write(line.replace('sortBy ( b ->', 'sortBy (\\a b ->'))
        elif '-> sortBy ( b -> compare (Game.id b) (Game.id a)) filteredGames' in line:
            f.write(line.replace('sortBy ( b ->', 'sortBy (\\a b ->'))
        elif '-> sortBy ( b -> compare (T.toLower $ Game.title a) (T.toLower $ Game.title b)) filteredGames' in line:
            f.write(line.replace('sortBy ( b ->', 'sortBy (\\a b ->'))
        else:
            f.write(line)
