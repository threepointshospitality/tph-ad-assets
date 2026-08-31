# tph-ad-assets

Public host for Meta ad creative.

## Why this repo exists

`ads_creative_upload_image` and `ads_creative_upload_video` fetch a **public URL with no
authentication**. Google Drive serves `text/html` from every endpoint it has —
`uc?export=download`, `lh3.googleusercontent.com/d/`, `drive.usercontent.google.com` —
so a Drive link always fails the upload. Local files can't be reached at all.

That blocker is why ad creative kept getting uploaded by hand through the Ads Manager UI.

## Use

```bash
./push-asset.sh ~/Downloads/OAK-Trivia-1-SERIES-universal-FEED-4x5-MOTION.mp4 oak
```

Prints a jsDelivr CDN URL. Hand that straight to `ads_creative_upload_video`
(or `_image`). Subdirs: `oak`, `cantina`, `bostwick`.

## What goes in here

Only creative that is going to run as a paid ad — it becomes public the moment it
serves, so the repo being public costs nothing. **Never** put source files, briefs,
pricing, contracts, or anything with staff or customer data in here.

Videos are a few MB each. Prune old flights periodically rather than letting this grow
without bound.
