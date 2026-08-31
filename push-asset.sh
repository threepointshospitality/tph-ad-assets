#!/usr/bin/env bash
# Publish an ad creative to a public URL that Meta's MCP uploader can actually fetch.
#
# Why: ads_creative_upload_image / ads_creative_upload_video fetch a public URL with
# no auth. Google Drive serves text/html from every endpoint (uc?export=download,
# lh3.googleusercontent.com/d/, drive.usercontent.google.com), so a Drive link ALWAYS
# fails. This repo is the fix.
#
#   ./push-asset.sh <file> [subdir]        subdir defaults to: oak
#
# Prints the CDN URL to hand to the MCP uploader.
set -euo pipefail

SRC="${1:?usage: push-asset.sh <file> [subdir]}"
SUB="${2:-oak}"
[ -f "$SRC" ] || { echo "no such file: $SRC" >&2; exit 1; }

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_DIR"

BASE="$(basename "$SRC")"
mkdir -p "$SUB"
cp "$SRC" "$SUB/$BASE"

git add "$SUB/$BASE"
if git diff --cached --quiet; then
  echo "unchanged, already published" >&2
else
  git commit -q -m "asset: $SUB/$BASE"
  git push -q origin HEAD
fi

BRANCH="$(git rev-parse --abbrev-ref HEAD)"
URL="https://cdn.jsdelivr.net/gh/threepointshospitality/tph-ad-assets@${BRANCH}/${SUB}/${BASE}"
RAW="https://raw.githubusercontent.com/threepointshospitality/tph-ad-assets/${BRANCH}/${SUB}/${BASE}"

echo "$URL"
echo "  fallback: $RAW" >&2
