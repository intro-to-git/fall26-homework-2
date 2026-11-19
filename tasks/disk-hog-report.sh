#!/bin/bash

usage() {
    echo "Usage: $0 N [DIR]" >&2
    echo "  N    number of largest files to show (positive integer)" >&2
    echo "  DIR  directory to scan (default: current directory)" >&2
    exit 1
}

if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    usage
fi

count=$1
dir=${2:-.}

if ! [[ $count =~ ^[1-9][0-9]*$ ]]; then
    echo "Error: N must be a positive integer, got '$count'" >&2
    usage
fi

if [ ! -d "$dir" ]; then
    echo "Error: '$dir' is not a directory" >&2
    exit 1
fi

find "$dir" -type f -exec du -k {} + 2>/dev/null \
    | sort -rn \
    | head -n "$count" \
    | awk -F'\t' '
        function human(kb,    units, i) {
            split("K M G T P", units, " ")
            i = 1
            while (kb >= 1024 && i < 5) {
                kb /= 1024
                i++
            }
            if (kb < 10 && i > 1) {
                return sprintf("%.1f%s", kb, units[i])
            }
            return sprintf("%d%s", kb + 0.5, units[i])
        }
        {
            total += $1
            name = $2
            sub(/^\.\//, "", name)
            printf "%6s  %s\n", human($1), name
        }
        END {
            if (NR == 0) {
                print "No files found."
            }
            printf "  Total: %s\n", human(total + 0)
        }'
