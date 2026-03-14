#!/bin/bash

set -e

cd blog
cat ../src/templates/blog_index_head.x > index.xml

# Loop through all .md files and extract the date
for file in `ls 0*.md | sort -r`; do
    # Extract the title
    title=$(grep -m 1 '^# ' "$file")
    title="${title#\# }"

    # Extract the date from the second line
    date=$(sed -n 's/^\*Published: \(.*\) - Last Updated: .*$/\1/p' "$file")

    url=$(basename "$file" .md).html

    # Append the information to the temporary file
    
    echo "<tr><td><a href=\"$url\">$title</a></td><td>$date</td></tr>" >> index.xml
    
done

echo "</table></content></section></sections></page>" >> index.xml

xsltproc -o index.html ../src/templates/article.xslt index.xml
# delete intermediate xml
rm index.xml
