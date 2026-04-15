import re

with open("app/Utils/Handles.hs", "r") as f:
    content = f.read()

content = content.replace("import Web.Scotty (ActionM, get, post, html, redirect, param, queryParamMaybe, body, pathParam, rescue)", "import Web.Scotty (ActionM, get, post, html, redirect, param, queryParamMaybe, body, pathParam, rescue, header)")

with open("app/Utils/Handles.hs", "w") as f:
    f.write(content)
