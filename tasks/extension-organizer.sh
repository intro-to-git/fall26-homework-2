#!/usr/bin/env bash

# Extension Organizer (issue #14)
# Sorts the files in a directory into subfolders by extension.
# Files without an extension go into "no_extension".

# Usage: ./extension-organizer.sh <directory>

if [ $# -ne 1 ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

dir="$1"

if [ ! -d "$dir" ]; then
    echo "Error: '$dir' is not a directory"
    exit 1
fi

# Prints the extension of a file name (lowercase, no dot), or nothing
get_extension() {
    local name="$1"
    if [[ "$name" =~ ^.+\.([^.]+)$ ]]; then
        echo "${BASH_REMATCH[1],,}"
    fi
}

declare -A counts
moved=0

shopt -s nullglob dotglob

for file in "$dir"/*; do
    if [ ! -f "$file" ]; then
        continue
    fi

    name=$(basename "$file")
    ext=$(get_extension "$name")

    if [ -z "$ext" ]; then
        folder="$dir/no_extension"
        label="(none)"
    else
        folder="$dir/$ext"
        label=".$ext"
    fi

    mkdir -p "$folder"
    mv -n "$file" "$folder/"

    counts["$label"]=$(( ${counts["$label"]:-0} + 1 ))
    moved=$(( moved + 1 ))
done

echo "Moved $moved files:"
for label in "${!counts[@]}"; do
    echo "${counts[$label]} $label"
done | sort -rn | while read -r count label; do
    echo "  $label -> $count"
done