#!/bin/bash
set -e

# Strip EXIF/XMP/IPTC metadata (camera model, timestamps, GPS) from images.
# Only touches files that still have metadata, so each image is re-encoded at most once.
# -auto-orient bakes the EXIF rotation into the pixels before the rotation tag is removed.
find img -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \) | while read -r file; do
    if identify -format '%[*]' "$file" 2>/dev/null | grep -qE '^(exif|xmp|iptc|8bim):'; then
        echo "Stripping metadata: $file"
        mogrify -auto-orient -strip "$file"
    fi
done
