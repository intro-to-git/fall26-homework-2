#!/bin/bash
#
# Git Largest Change Finder (issue #7)
#
# Finds the single commit that changed the most lines (lines added + lines
# deleted) and prints its author, short hash and the total.
#
# Usage:
#   ./git-largest-change-finder.sh [repo-path]
#
#   repo-path   path to a git repository (default: current directory)
#
# Example output:
#   alice f0e9d8c 342 lines changed

set -euo pipefail

usage() {
    echo "Usage: $0 [repo-path]"
}

if [ "$#" -gt 1 ]; then
    usage >&2
    exit 1
fi

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    usage
    exit 0
fi

repo="${1:-.}"

if ! git -C "$repo" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Error: '$repo' is not inside a git repository" >&2
    exit 1
fi

if ! git -C "$repo" rev-parse --verify --quiet HEAD >/dev/null; then
    echo "Error: the repository has no commits yet" >&2
    exit 1
fi

# For every commit, git prints a header line "@@<hash>|<author>" followed by
# one numstat line per file: "<added><TAB><deleted><TAB><path>".
# Binary files show "-" instead of numbers, so they are not counted.
# Merge commits have no numstat output, so they count as 0.
git -C "$repo" log --no-color --numstat --format='@@%h|%aN' | awk -F'\t' '
    function finish_commit() {
        if (hash != "" && total > max_total) {
            max_total  = total
            max_hash   = hash
            max_author = author
        }
    }

    BEGIN { max_total = -1 }

    /^@@/ {
        finish_commit()
        header = substr($0, 3)
        sep    = index(header, "|")      # the hash never contains "|"
        hash   = substr(header, 1, sep - 1)
        author = substr(header, sep + 1)
        total  = 0
        next
    }

    NF >= 3 && $1 ~ /^[0-9]+$/ && $2 ~ /^[0-9]+$/ {
        total += $1 + $2
    }

    END {
        finish_commit()
        printf "%s %s %d lines changed\n", max_author, max_hash, max_total
    }
'
