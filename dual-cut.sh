#!/usr/bin/env bash
# One source flyer -> BOTH required cuts (4:5 feed + 9:16 story/reels), published to CDN.
#
# Why this exists: the standing rule in the meta-ads-launch skill is "render 4:5 AND 9:16
# for every creative, every time." On 9/1 a Gators trivia ad shipped 9:16-only; Meta
# pre-cropped it to 3:4 in Feed and silently ate the OAK stamp and the entire
# "WEEKLY PRIZES + GRAND PRIZE: UNIVERSAL TRIP" bar. The rule was already written down.
# What was missing was a one-command way to obey it.
#
#   ./dual-cut.sh <source.png> [subdir] [basename]
#
# Prints both CDN URLs, ready to hand straight to ads_creative_upload_image.
#
# NOTE ON QUALITY: this derives the missing ratio by CONTAIN + sampled-background pad,
# so nothing is ever amputated. It is a safety net, not a substitute for art composed
# at the target ratio. A purpose-built 4:5 will always read better -- type is larger and
# the layout breathes. Use this when speed wins; commission the real cut when it matters.
set -euo pipefail

SRC="${1:?usage: dual-cut.sh <source.png> [subdir] [basename]}"
SUB="${2:-oak}"
[ -f "$SRC" ] || { echo "no such file: $SRC" >&2; exit 1; }

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE="${3:-$(basename "${SRC%.*}")}"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

W=$(magick identify -format "%w" "$SRC")
H=$(magick identify -format "%h" "$SRC")
RATIO=$(awk -v w="$W" -v h="$H" 'BEGIN{printf "%.4f", w/h}')
echo "source: ${W}x${H}  (ratio ${RATIO})" >&2

# Sample the background from a corner so the pad matches the art instead of adding
# black bars to a not-quite-black flyer.
BG=$(magick "$SRC" -format "%[pixel:p{20,20}]" info:)
echo "sampled background: $BG" >&2

FEED="$WORK/${BASE}-FEED-4x5.png"      # 1080x1350
STORY="$WORK/${BASE}-STORY-9x16.png"   # 1080x1920

# 4:5 == 0.8000, 9:16 == 0.5625. Anything within 1% counts as already correct.
is_ratio() { awk -v a="$RATIO" -v b="$1" 'BEGIN{exit !(a>b*0.99 && a<b*1.01)}'; }

if is_ratio 0.8000; then
  echo "source is already 4:5 -> using as feed cut" >&2
  magick "$SRC" -resize 1080x1350 "$FEED"
else
  magick "$SRC" -resize 1080x1350 -background "$BG" -gravity center -extent 1080x1350 "$FEED"
fi

if is_ratio 0.5625; then
  echo "source is already 9:16 -> using as story cut" >&2
  magick "$SRC" -resize 1080x1920 "$STORY"
else
  magick "$SRC" -resize 1080x1920 -background "$BG" -gravity center -extent 1080x1920 "$STORY"
fi

for f in "$FEED" "$STORY"; do
  echo "  built $(basename "$f") -> $(magick identify -format '%wx%h' "$f")" >&2
done

echo "" >&2
for f in "$FEED" "$STORY"; do
  "$REPO_DIR/push-asset.sh" "$f" "$SUB" | head -1
done

echo "" >&2
echo "LOOK AT BOTH FILES before uploading. Preview every placement after building the ad:" >&2
echo "  MOBILE_FEED_STANDARD, INSTAGRAM_STANDARD, INSTAGRAM_STORY, INSTAGRAM_REELS" >&2
