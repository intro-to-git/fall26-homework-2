#!/usr/bin/env bash

# Naming Convention Fixer (issue #17)
# Renames the files in a directory to YYYY-MM-DD_slug.ext
#
#   My Photo (1).jpg    -> 2024-03-11_my-photo.jpg   (date from the file's timestamp)
#   IMG_2023-07-14.PNG  -> 2023-07-14_img.png        (date from the name)
#
# Usage: ./naming-convention-fixer.sh <directory> [--dry-run]
#   --dry-run   only show what would be renamed, without changing anything

if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    echo "Usage: $0 <directory> [--dry-run]"
    exit 1
fi

dir="$1"
dry_run=false

if [ $# -eq 2 ]; then
    if [ "$2" != "--dry-run" ]; then
        echo "Usage: $0 <directory> [--dry-run]"
        exit 1
    fi
    dry_run=true
fi

if [ ! -d "$dir" ]; then
    echo "Error: '$dir' is not a directory"
    exit 1
fi

renamed=0
declare -A planned   # new names used so far

for path in "$dir"/*; do
    # Only regular files; skip folders
    if [ ! -f "$path" ]; then
        continue
    fi

    name=$(basename "$path")

    # Split the name into base name and extension (lowercase)
    if [[ "$name" == *.* ]]; then
        base="${name%.*}"
        ext=".${name##*.}"
        ext="${ext,,}"
    else
        base="$name"
        ext=""
    fi

    # Take the date from the name (2024-03-11, 2024_03_11 or 20240311) if it has
    # a valid one, otherwise from the file's last modification time
    date=""
    if [[ "$base" =~ ([0-9]{4})[-_.]?([0-9]{2})[-_.]?([0-9]{2}) ]]; then
        found="${BASH_REMATCH[1]}-${BASH_REMATCH[2]}-${BASH_REMATCH[3]}"
        if [ "$(date -d "$found" +%F 2>/dev/null)" = "$found" ]; then
            date="$found"
            base="${base/"${BASH_REMATCH[0]}"/ }"
        fi
    fi
    if [ -z "$date" ]; then
        date=$(date -r "$path" +%F)
    fi

    # Remove copy numbers like "(1)" or "(2)"
    while [[ "$base" =~ \([0-9]+\) ]]; do
        base="${base/"${BASH_REMATCH[0]}"/ }"
    done

    # Make the slug: lowercase, anything that isn't a letter or digit becomes "-"
    slug=$(echo "${base,,}" | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')
    if [ -z "$slug" ]; then
        slug="file"
    fi

    new_name="${date}_${slug}${ext}"

    # Already follows the convention
    if [ "$new_name" = "$name" ]; then
        continue
    fi

    # Don't overwrite another file: add -2, -3, ... if the name is taken
    # (also checks names already planned, so --dry-run shows the real result)
    i=2
    while [ -e "$dir/$new_name" ] || [ -n "${planned[$new_name]}" ]; do
        new_name="${date}_${slug}-${i}${ext}"
        i=$((i + 1))
    done
    planned["$new_name"]=1

    if [ "$dry_run" = true ]; then
        echo "Would rename: $name -> $new_name"
    else
        mv -n -- "$path" "$dir/$new_name"
        echo "Renamed: $name -> $new_name"
    fi
    renamed=$((renamed + 1))
done

if [ "$dry_run" = true ]; then
    echo "Would rename $renamed files."
else
    echo "Renamed $renamed files."
fi