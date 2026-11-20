#!/bin/bash

# first let's check if we are inside a git repository
# otherwise git log won't work
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "Not a git repository"
    exit 1
fi

# now we need to find files that were deleted in previous commits
# D stands for deleted, name-only shows just file names
# sed removes empty lines, sort -u removes duplicates
deleted=$(git log --all --diff-filter=D --name-only --format= | sed '/^$/d' | sort -u)

# if the list is empty, there is nothing to recover
if [ -z "$deleted" ]; then
    echo "No deleted files found"
    exit 0
fi

# show the deleted files we found
echo "Deleted files:"
printf '%s\n' "$deleted"

# ask which file we want to bring back
echo "Enter the file name to recover:"
read -r file

# check if this file is actually in our list
if ! printf '%s\n' "$deleted" | grep -Fxq -- "$file"; then
    echo "File not found in deleted files"
    exit 1
fi

# find the commit where this file was deleted
commit=$(git log --all --diff-filter=D --format=%H -- "$file" | head -n 1)

# the file existed right before that commit
# so we need to get its previous version
if [ -z "$commit" ]; then
    echo "Could not find the deletion commit"
    exit 1
fi

# create a folder for recovered files
mkdir -p "recovered/$(dirname "$file")"

# get the file from the parent commit
if git show "${commit}^:$file" > "recovered/$file"; then
    echo "File recovered: recovered/$file"
else
    echo "Recovery failed"
    rm -f "recovered/$file"
    exit 1
fi
