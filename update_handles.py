import re

with open("app/Utils/Handles.hs", "r") as f:
    content = f.read()

# Replace postEdit redirect
content = re.sub(
    r'Right _ -> redirect "/backlog"',
    r'''Right _ -> do
                    referer <- header "Referer"
                    case referer of
                        Just ref -> redirect ref
                        Nothing -> redirect "/backlog"''',
    content
)

# Replace postDelete redirect
content = re.sub(
    r'liftIO \$ DB\.deleteGame gameId\n    redirect "/backlog"',
    r'''liftIO $ DB.deleteGame gameId
    referer <- header "Referer"
    case referer of
        Just ref -> redirect ref
        Nothing -> redirect "/backlog"''',
    content
)

with open("app/Utils/Handles.hs", "w") as f:
    f.write(content)
