#!/bin/bash
# Generate blog/category/<pagename>.html for every category used by a .md page.
# Prints the category list (HTML links) on stdout for the blog index.
set -e

source src/lib-categories.sh

rows=$(mktemp)
trap 'rm -f "$rows"' EXIT

# Same file set as the Makefile
find . -mindepth 2 -name '*.md' -not -path './src/*' -not -path './img/*' | while read -r file; do
    cats=$(get_categories "$file")
    [ -z "$cats" ] && continue

    title=$(grep -m 1 '^# ' "$file")
    title="${title#\# }"

    # Prefer the Published date, fall back to Last Updated
    date=$(grep -m 1 -o 'Published: [0-9A-Za-z-]*' "$file" | sed 's/^Published: //' || true)
    if [ -z "$date" ]; then
        date=$(grep -m 1 -o 'Last Updated: [0-9A-Za-z-]*' "$file" | sed 's/^Last Updated: //' || true)
    fi
    sortkey=$(date -d "$date" +%Y%m%d 2>/dev/null || echo 00000000)

    url="/${file#./}"
    url="${url%.md}.html"

    while read -r name; do
        printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$(category_pagename "$name")" "$name" "$sortkey" "$date" "$title" "$url" >> "$rows"
    done <<< "$cats"
done

mkdir -p blog/category
rm -f blog/category/*.html

for pagename in $(cut -f1 "$rows" | sort -u); do
    # Display name: first spelling seen for this category
    name=$(awk -F'\t' -v p="$pagename" '$1 == p { print $2; exit }' "$rows")
    xmlfile="blog/category/$pagename.xml"

    sed "s|@CATEGORY@|$name|g" src/templates/category_head.x > "$xmlfile"
    awk -F'\t' -v p="$pagename" '$1 == p' "$rows" | sort -t $'\t' -k3,3r -k5,5 | \
        while IFS=$'\t' read -r _ _ _ date title url; do
            echo "<tr><td><a href=\"$url\">$title</a></td><td>$date</td></tr>" >> "$xmlfile"
        done
    echo "</table></content></section></sections></page>" >> "$xmlfile"

    xsltproc -o "blog/category/$pagename.html" src/templates/article.xslt "$xmlfile"
    rm "$xmlfile"
done

# Category list for the blog index, alphabetical by display name
cut -f1,2 "$rows" | sort -u -t $'\t' -k1,1 | sort -f -t $'\t' -k2,2 | \
    while IFS=$'\t' read -r pagename name; do
        count=$(awk -F'\t' -v p="$pagename" '$1 == p' "$rows" | cut -f6 | sort -u | wc -l)
        echo "<a href=\"category/$pagename.html\">$name</a> ($count)<br></br>"
    done
