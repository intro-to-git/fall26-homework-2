#!/bin/bash

FILE="$1"

if [ -z "$FILE" ]; then
    echo "Usage: $0 <file>"
    exit 1
fi

COMMIT=$(git rev-parse --short HEAD)

echo "File: $FILE (commit: $COMMIT)"
echo

git blame --line-porcelain "$FILE" |
grep "^author " |
sed 's/^author //' |
sort |
uniq -c |
sort -rn |
awk '{print $2 "\t" $1}'

