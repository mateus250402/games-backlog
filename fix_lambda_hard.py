import re

with open("app/Utils/Handles.hs", "r") as f:
    content = f.read()

content = re.sub(r'sortBy \( b ->', r'sortBy (\\a b ->', content)

with open("app/Utils/Handles.hs", "w") as f:
    f.write(content)
