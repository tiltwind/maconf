#!/bin/bash
# export-pdf-to-images.sh
# Convert each page of a PDF file to PNG images in a temporary directory.
# Usage: export-pdf-to-images.sh <pdf-file>
# Requires: pdftoppm (from poppler, install via: sudo port install poppler)

set -e

if [ $# -lt 1 ]; then
    echo "Usage: $0 <pdf-file>"
    exit 1
fi

PDF_FILE="$1"

if [ ! -f "$PDF_FILE" ]; then
    echo "Error: file not found: $PDF_FILE"
    exit 1
fi

if ! command -v pdftoppm &>/dev/null; then
    echo "Error: pdftoppm not found. Install poppler:"
    echo "  sudo port install poppler"
    echo "  or: brew install poppler"
    exit 1
fi

BASENAME=$(basename "$PDF_FILE" .pdf)
TMPDIR=$(mktemp -d "/tmp/${BASENAME}_XXXXXX")

echo "Converting: $PDF_FILE"
echo "Output dir: $TMPDIR"

pdftoppm -png -r 300 "$PDF_FILE" "${TMPDIR}/page"

# Rename page-01.png, page-02.png ... to 1.png, 2.png ...
INDEX=1
for f in $(ls "${TMPDIR}"/page-*.png 2>/dev/null | sort); do
    mv "$f" "${TMPDIR}/${INDEX}.png"
    INDEX=$((INDEX + 1))
done

TOTAL=$((INDEX - 1))
echo "Done: ${TOTAL} pages exported to ${TMPDIR}"

open "$TMPDIR"
