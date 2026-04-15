with open("app/Components/GameCard.hs", "r") as f:
    text = f.read()

old_title = 'font-size: 1.15rem; line-height: 1.2; max-width: 240px; display: block; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; margin-bottom: 0 !important; padding-bottom: 0 !important;'
new_title = 'font-size: 0.95rem; line-height: 1.1; max-width: 200px; display: block; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; margin-bottom: 0 !important; padding-bottom: 0 !important;'

old_info = 'font-size: 0.9rem; line-height: 1.2; margin-top: 0 !important; padding-top: 0 !important; opacity: 0.9;'
new_info = 'font-size: 0.75rem; line-height: 1.1; margin-top: 0 !important; padding-top: 0 !important; opacity: 0.9;'

text = text.replace(old_title, new_title)
text = text.replace(old_info, new_info)

with open("app/Components/GameCard.hs", "w") as f:
    f.write(text)
