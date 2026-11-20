#!/bin/bash
# Fixed issue (#10)
# https://github.com/intro-to-git/fall26-homework-2/issues/10

git log --date=format:%Y-%m --pretty=format:%ad |
sort | uniq -c | sort -k2 -r |
while read count month; do
    BAR=""

    for ((i=0; i<count; i++)); do
        BAR="${BAR}█"
    done

    echo "$month $BAR $count"
done

