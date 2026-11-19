#!/bin/bash

# Check that a filename was provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <filename>"
    exit 1
fi

file="$1"

# Check that the file exists
if [ ! -f "$file" ]; then
    echo "Error: File not found: $file"
    exit 1
fi

# Check that Git can find the file in the repository
if ! git ls-files --error-unmatch -- "$file" >/dev/null 2>&1; then
    echo "Error: File is not tracked by Git."
    exit 1
fi

# Get the latest commit hash
commit=$(git rev-parse --short HEAD)

# Count how many lines belong to each author
report=$(git blame --line-porcelain -- "$file" |
    sed -n 's/^author //p' |
    sort |
    uniq -c |
    sort -rn)

if [ -z "$report" ]; then
    echo "No lines found in $file"
    exit 0
fi

# Save the report to a text file
{
    echo "File: $file (commit: $commit)"
    echo "$report" | awk '{count=$1; $1=""; sub(/^ /, ""); printf "  %-20s %s\n", $0, count}'
} > blame_report.txt

echo "Report saved to blame_report.txt"
cat blame_report.txt
