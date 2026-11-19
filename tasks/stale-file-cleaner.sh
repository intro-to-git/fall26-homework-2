#!/bin/bash


DAYS="$1"

DRY_RUN=false

if [[ "$2" == "--dry-run" ]]; then
    DRY_RUN=true
elif [[ -n "$2" ]]; then
    echo "unknown argument $2"
    exit 1
fi

TRASH_DIR="./trash"

mapfile -d '' OLD_FILES < <(find . -type f -mtime +"$DAYS" ! -path "./trash/*" -print0)

FILE_COUNT=${#OLD_FILES[@]}

if [[ "$FILE_COUNT" -eq 0 ]]; then
    echo "No files older than $DAYS days were found."
    exit 0
fi

if [[ "$DRY_RUN" == true ]]; then
    echo "Move $FILE_COUNT files older than $DAYS days:"

    for FILE in "${OLD_FILES[@]}"; do
        echo "  $FILE"
    done

    exit 0
fi

mkdir -p "$TRASH_DIR"

for FILE in "${OLD_FILES[@]}"; do
    mv -- "$FILE" "$TRASH_DIR/"
done

echo "Moved $FILE_COUNT files older than $DAYS days to $TRASH_DIR."