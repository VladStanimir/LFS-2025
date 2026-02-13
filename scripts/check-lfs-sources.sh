#!/usr/bin/env bash

set -e

LINK_FILE="./sources-image/source-archive-links.txt"
SRC_DIR="./sources-image/sources"

if [ ! -f "$LINK_FILE" ]; then
    echo "ERROR: Link file not found: $LINK_FILE"
    exit 1
fi

if [ ! -d "$SRC_DIR" ]; then
    echo "ERROR: Source directory not found: $SRC_DIR"
    exit 1
fi

echo "Checking downloaded sources..."
missing=0

while read -r url; do
    # skip empty lines or comments
    [[ -z "$url" ]] && continue
    [[ "$url" =~ ^# ]] && continue

    # extract filename from URL
    fname=$(basename "$url")

    if [ ! -f "$SRC_DIR/$fname" ]; then
        echo "MISSING: $fname"
        missing=$((missing+1))
    fi
done < "$LINK_FILE"

echo "----------------------------------------------------"

if [ "$missing" -eq 0 ]; then
    echo "All files are present!"
else
    echo "Total missing files: $missing"
    echo "Please download missing files."
    exit 2
fi
