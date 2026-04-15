with open("app/Utils/Handles.hs", "r") as f:
    text = f.read()

text = text.replace('\x07 b -> compare', '\\a b -> compare')

with open("app/Utils/Handles.hs", "w") as f:
    f.write(text)
