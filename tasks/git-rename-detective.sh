#!/bin/bash
#
# Git Rename Detective
# Traces renamed files through git history and prints the rename chain:
#   old -> new   (commit, date)
#
# Usage:
#   ./git-rename-detective.sh            # show every rename in the repo
#   ./git-rename-detective.sh <file>     # follow the rename chain of one file

if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "Error: not inside a git repository" >&2
    exit 1
fi

if [ $# -gt 1 ]; then
    echo "Usage: $0 [file]" >&2
    exit 1
fi

# -M detects renames, --diff-filter=R keeps only renames
if [ $# -eq 1 ]; then
    log_output=$(git log --follow -M --diff-filter=R --name-status \
        --format="COMMIT %h %ad" --date=short -- "$1")
else
    log_output=$(git log -M --diff-filter=R --name-status \
        --format="COMMIT %h %ad" --date=short)
fi

if [ -z "$log_output" ]; then
    echo "No renames found."
    exit 0
fi

# Parse the log (newest first), collect lines, then print them reversed
results=()
commit=""
date=""
while IFS=$'\t' read -r status old new; do
    if [[ "$status" == COMMIT* ]]; then
        read -r _ commit date <<< "$status"
    elif [[ "$status" == R* ]]; then
        results+=("$(printf "%-30s (%s, %s)" "$old -> $new" "$commit" "$date")")
    fi
done <<< "$log_output"

for (( i=${#results[@]}-1; i>=0; i-- )); do
    echo "${results[i]}"
done
