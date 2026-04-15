import re

with open("app/Pages/Backlog.hs", "r") as f:
    content = f.read()

# Fix checked_ "" -> checked_
content = content.replace("checked_ \"\"", "checked_")

# Fix selected_ "" -> selected_
content = content.replace("selected_ \"\"", "selected_")

with open("app/Pages/Backlog.hs", "w") as f:
    f.write(content)
