
#!/bin/bash

set -e


cat index.md > index_stage.md
echo "## Recent Blog Articles" >> index_stage.md


# Loop through all .md files and extract the date
for file in `ls blog/0*.md | sort -r`; do
    # Extract the title
    title=$(grep -m 1 '^# ' "$file")
    title="${title#\# }"

    # Extract the date from the second line
    date=$(sed -n 's/^\*Published: \(.*\) - Last Updated: .*$/\1/p' "$file")

    url="${file%.md}.html"

    # Skip first 2 lines, drop empty lines, take first remaining line, trim to 300 chars
    first_100=$(tail -n +3 "$file" | grep -v '^$' | head -1 | cut -c1-300)

    echo "\n---\n" >> index_stage.md
    echo "[**$title - $date**]($url)  " >> index_stage.md
    echo "$first_100...  " >> index_stage.md


    # Break out of loop after 10 runs
    count=$((count + 1))
    [ $count -ge 7 ] && break
    
done
 
 echo "\n---\n" >> index_stage.md
 echo "[All Blog Article](/blog/index.html)" >> index_stage.md

src/gen-page.sh index_stage.md

mv index_stage.html index.html
# delete intermediate md

rm index_stage.md


