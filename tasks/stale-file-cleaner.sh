#!/bin/bash

if [ $# -lt 1 ] || [ $# -gt 2 ] || ! [[ "$1" =~ ^[0-9]+$ ]] || [ "$1" -eq 0 ]; then
    echo "Usage: $0 DAYS [--dry-run]"
    exit 1
fi

days="$1"
mode="${2:-}"
count=0

if [ -n "$mode" ] && [ "$mode" != "--dry-run" ]; then
    echo "Invalid option"
    exit 1
fi

while IFS= read -r -d '' file; do

    if [ "$mode" = "--dry-run" ]; then
        echo "[dry-run] Would move: $file"
    else
        destination="trash/${file#./}"
        mkdir -p "$(dirname "$destination")"

        if mv -n "$file" "$destination"; then
            echo "Processed: $file"
        else
            echo "Error moving: $file" >&2
            continue
        fi
    fi

    count=$((count + 1))

done < <(find . -type f -mtime +"$days" \
    ! -path "./.git/*" \
    ! -path "./trash/*" \
    -print0)

echo "Total files processed: $count"
