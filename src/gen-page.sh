#!/bin/bash
set -e

file="$1"
xmlfile="${file%.md}.xml"
trap 'rm -f "$xmlfile"' EXIT

htmlfile="${file%.md}.html"

# Extract the title
title=$(grep -m 1 '^# ' "$file")
title="${title#\# }"

# Identify theme based on parent directory
parentdir=$(basename $(dirname "$file"))
case $parentdir in 
    sgi)
        theme=$parentdir
        termtitle="winterm"
        ;;
    hp)
        theme=$parentdir
        termtitle="hpterm"
        ;;
    dec)
        theme=$parentdir
        termtitle="DECterm"
        ;;
    ibm)
        theme=$parentdir
        termtitle="dtterm"
        ;;
    sun)
        theme=$parentdir
        termtitle="Terminal"
        ;;
    *)
        theme="default"
        termtitle="Terminal"
        ;;
esac

# Generate the XML file
cat src/templates/header.x > "$xmlfile"
markdown "$file" >> "$xmlfile"
cat src/templates/footer.x >> "$xmlfile"

# Replace placeholders
sed -i "s/@THEME@/$theme/" "$xmlfile"
sed -i "s|@TITLE@|$title|" "$xmlfile"

# Replace each remaining <h2> with a window-break section + <h2>
sed -i 's|<h2[^>]*>\(.*\)</h2>|</content></section>\n<section><window-title>@TERMTITLE@ - \1</window-title>\n<content>\n<h2>\1</h2>|' "$xmlfile"
# Finally replace termtitle
sed -i "s/@TERMTITLE@/$termtitle/" "$xmlfile"

xsltproc -o "$htmlfile" src/templates/article.xslt "$xmlfile"
# delete intermediate xml
rm "$xmlfile"
