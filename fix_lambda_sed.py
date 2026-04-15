import re

with open("app/Utils/Handles.hs", "r") as f:
    content = f.read()

content = content.replace("sortBy ( b ->", "sortBy (\\a b ->")

with open("app/Utils/Handles.hs", "w") as f:
    f.write(content)
