#!/bin/bash
# cut-video-bottom.sh
# Crop N pixels from the bottom of a video.
# Usage: cut-video-bottom.sh <pixels> <input.mp4>
# Output: <input>-output.mp4
# Requires: ffmpeg

set -e

if [ $# -lt 2 ]; then
    echo "Usage: $0 <pixels> <input.mp4>"
    exit 1
fi

PIXELS="$1"
INPUT="$2"

if [ ! -f "$INPUT" ]; then
    echo "Error: file not found: $INPUT"
    exit 1
fi

if ! command -v ffmpeg &>/dev/null; then
    echo "Error: ffmpeg not found. Install via:"
    echo "  sudo port install ffmpeg"
    echo "  or: brew install ffmpeg"
    exit 1
fi

DIR=$(dirname "$INPUT")
BASENAME=$(basename "$INPUT")
EXT="${BASENAME##*.}"
NAME="${BASENAME%.*}"
OUTPUT="${DIR}/${NAME}-output.${EXT}"

echo "Cropping ${PIXELS}px from bottom: $INPUT -> $OUTPUT"

ffmpeg -i "$INPUT" -vf "crop=iw:ih-${PIXELS}:0:0" -c:a copy "$OUTPUT"

echo "Done: $OUTPUT"
