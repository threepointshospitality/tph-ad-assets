# inherits: ~/.claude/CLAUDE.md

## Purpose
Public GitHub repo (`threepointshospitality/tph-ad-assets`) hosting paid-ad creative for Three Points Hospitality (OAK, Cantina Añejo).
Meta's `ads_creative_upload_image` / `_video` fetch a public URL with no auth; Drive links always return `text/html` and fail. This repo serves files via jsDelivr instead.
Used by the Meta ads workflow (meta-ads-launch skill, tph-ads-operator agent).

## Layout and naming
- `oak/` (11 files: PNG + MP4), `cantina/` and `bostwick/` (empty on disk, so untracked by git; README lists all three as valid subdirs).
- Names carry both ratios: `<Campaign>-FEED-4x5.<ext>` (1080x1350) and `<Campaign>-STORY-9x16.<ext>` (1080x1920); videos add `-MOTION` (e.g. `OAK-Trivia-1-SERIES-universal-FEED-4x5-MOTION.mp4`).
- Commits are auto-generated, one per file: `asset: <subdir>/<file>`.

## Commands
- `/Users/devin/claude-os/projects/tph-ad-assets/push-asset.sh <file> [subdir]` : copies into `<subdir>` (default `oak`), commits, runs `git push origin HEAD`, prints the jsDelivr URL (raw.githubusercontent fallback to stderr). It commits and pushes the WHOLE index, not only the named file: run `git status` first and make sure nothing else is staged. It publishes to a PUBLIC repo at once and a CDN copy cannot be reliably recalled: confirm the exact file with Devin before running it.
- `/Users/devin/claude-os/projects/tph-ad-assets/dual-cut.sh <source.png> [subdir] [basename]` : builds 4:5 and 9:16 cuts with ImageMagick (`magick`), publishes both through `push-asset.sh`. Same rules: confirm first, clean index, on `main`.
- No build, test or install step.

## Key files
- `README.md` : why the repo exists and what may go in it.
- `push-asset.sh`, `dual-cut.sh` : the only tooling.

## Data and connections
- No credential key names: no `.env*` or `.env.example` present. Pushes use the local git/`gh` auth for the `threepointshospitality` org.
- Consumers: Meta Ads MCP uploaders take the CDN URL `https://cdn.jsdelivr.net/gh/threepointshospitality/tph-ad-assets@<branch>/<subdir>/<file>`.

## Gotchas
- Public repo: only creative that is going to run as a paid ad. Never source files, briefs, pricing, contracts, staff or customer data (README).
- `push-asset.sh` pushes immediately and the URL is built from the CURRENT branch name; run it on `main` or the CDN URL points at that branch.
- Render 4:5 AND 9:16 for every creative. A 9/1 Gators ad shipped 9:16-only and Meta cropped away the stamp and prize bar (`dual-cut.sh` header).
- `dual-cut.sh` pads (contain + sampled background), it does not recompose; a purpose-built 4:5 reads better. Look at both outputs, then preview MOBILE_FEED_STANDARD, INSTAGRAM_STANDARD, INSTAGRAM_STORY, INSTAGRAM_REELS.
- Videos are a few MB each; prune old flights rather than letting the repo grow (README).
