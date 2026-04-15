import re
with open("app/Utils/Handles.hs", "r") as f:
    text = f.read()

text = text.replace('sortBy ( b ->', 'sortBy (\\a b ->')

with open("app/Utils/Handles.hs", "w") as f:
    f.write(text)
