#!/bin/bash

directory="${1:-.}"

if [ ! -d "$directory" ]; then
    echo "Error: directory does not exist"
    exit 1
fi

directory=$(cd "$directory" && pwd)
report="$(pwd)/inventory.txt"

# Convert bytes into readable sizes.
format_size() {
    if [ "$1" -lt 1000 ]; then
        echo "${1}B"
    else
        numfmt --to=si --format='%.1f' "$1"
    fi
}

{
    echo "Total files: $(find "$directory" -type f ! -path "$report" | wc -l)"

    total=$(find "$directory" -type f ! -path "$report" -printf '%s\n' |
        awk '{ sum += $1 } END { printf "%.0f", sum }')

    echo "Total size: $(format_size "$total")"

    extensions=$(find "$directory" -type f ! -path "$report" -printf '%f\n' |
        awk '{
            if ($0 ~ /\./ && $0 !~ /^\.[^.]+$/) {
                sub(/^.*\./, "", $0)
                print "." tolower($0)
            } else {
                print "other"
            }
        }' | sort | uniq -c |
        awk '{ printf "%s%s %s", (NR == 1 ? "" : ", "), $2, $1 }')

    echo "By extension: $extensions"

    echo "Largest 5:"

    find "$directory" -type f ! -path "$report" -printf '%s\t%p\n' |
        sort -nr | head -5 |
        while IFS=$'\t' read -r size file; do
            readable=$(format_size "$size")
            echo "  ${file##*/} ($readable)"
        done

    echo "Oldest 5:"

    find "$directory" -type f ! -path "$report" -printf '%T@\t%TY-%Tm-%Td\t%p\n' |
        sort -n | head -5 |
        while IFS=$'\t' read -r timestamp date file; do
            echo "  ${file##*/} ($date)"
        done

} > "$report"

echo "Report saved to $report"