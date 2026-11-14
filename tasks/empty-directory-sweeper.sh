#!/bin/bash

count=0
find . -type d -empty ! -path "./.git/*" | while read dir
do
    echo "Remove directory: $dir ? (y/n)"
    read answer

    if [ "$answer" = "y" ]; then
        rmdir "$dir"
        count=$((count + 1))
    fi
done

echo "Removed $count empty directories."