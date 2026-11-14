#!/bin/bash
set -e

source src/lib-categories.sh

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
cats=$(get_categories "$file")
if [ -n "$cats" ]; then
    # Replace the "Categories:" line with links to each category page
    links=""
    while read -r name; do
        [ -n "$links" ] && links="$links, "
        links="$links[$name](/blog/category/$(category_pagename "$name").html)"
    done <<< "$cats"
    awk -v links="*Categories: $links*" '/^Categories:/ && !done { print links; done=1; next } { print }' "$file" \
        | markdown >> "$xmlfile"
else
    markdown "$file" >> "$xmlfile"
fi
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
