#!/usr/bin/env bash

# Word Frequency Analyzer (issue #20)
# Writes the N most frequent words in a file to report.txt.
#
# Usage: ./word-frequency.sh <file> <N>

REPORT="report.txt"

if [ $# -ne 2 ]; then
    echo "Usage: $0 <file> <N>"
    exit 1
fi

file="$1"
count="$2"

if [ ! -f "$file" ]; then
    echo "Error: '$file' is not a file"
    exit 1
fi

if [[ ! "$count" =~ ^[1-9][0-9]*$ ]]; then
    echo "Error: N must be a positive whole number"
    exit 1
fi

{
    echo "Word frequency for $(basename "$file"):"

    # Remove punctuation, make everything lowercase, put one word per line,
    # then count the words and keep the N most frequent ones
    tr -d '[:punct:]' < "$file" |
        tr '[:upper:]' '[:lower:]' |
        tr -s '[:space:]' '\n' |
        grep -v '^$' |
        sort | uniq -c |
        sort -k1,1nr -k2,2 |
        head -n "$count" |
        awk '{ printf "%-10s %s\n", $2, $1 }'
} > "$REPORT"

echo "Report saved to $REPORT"