#!/bin/bash
set -e

BASE_URL="https://$(cat CNAME)"

{
    echo '<?xml version="1.0" encoding="UTF-8"?>'
    echo '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'

    find . -name '*.html' -not -path './src/*' | while read file; do
        url="${file#./}"
        date=$(date -r "$file" +%Y-%m-%d)
        echo "  <url>"
        echo "    <loc>$BASE_URL/$url</loc>"
        echo "    <lastmod>$date</lastmod>"
        echo "  </url>"
    done

    echo '</urlset>'
} > sitemap.xml