#!/bin/bash
# Shared helpers for page categories.
# A page declares categories with a line like:
#   Categories: SGI, Linux, Itanium

# Turn a category name into its page name: lowercase, runs of
# non-alphanumerics become '-'.  "SGI Altix" -> "sgi-altix"
category_pagename() {
    echo "$1" | tr '[:upper:]' '[:lower:]' | sed -e 's/[^a-z0-9]\{1,\}/-/g' -e 's/^-//' -e 's/-$//'
}

# Print one trimmed category name per line from the first
# "Categories:" line of a file. Prints nothing if there is none.
get_categories() {
    grep -m 1 '^Categories:' "$1" \
        | sed 's/^Categories:[[:space:]]*//' \
        | tr ',' '\n' \
        | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' \
        | grep -v '^$' || true
}
