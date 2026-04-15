with open("app/Utils/Handles.hs", "r") as f:
    text = f.read()

text = text.replace('Game.id', 'Game.gameId')

with open("app/Utils/Handles.hs", "w") as f:
    f.write(text)
