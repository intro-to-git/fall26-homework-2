#!/bin/bash

# Validation: check if the user actually typed a valid
if [ -z "$1" ]; then
  echo "Usage: $0 <search-string>"
  echo "Example: $0 parser"
  exit 1
fi

# save the given word
search="$1"

# print a header so the output is easy to read
echo "Searching for \"$search\":"

# look through git history for commits that added or removed the word
# -S finds where the word was added or deleted
# --stat shows which files changed and how many lines were added/removed
# --pretty=format prints: short hash, author name, date, and commit message
git log -S "$search" --stat --date=short --pretty=format:"%h  %an  %ad  %s"
