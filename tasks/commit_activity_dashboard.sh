#!/bin/bash

# make sure both start and end dates are provided
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <start-date> <end-date>"
  echo "Example: $0 01.01.2026 01.03.2026"
  exit 1
fi

start="$1"
end="$2"

# validate that both dates are in DD.MM.YYYY format
if ! [[ "$start" =~ ^[0-9]{2}\.[0-9]{2}\.[0-9]{4}$ ]]; then
  echo "start date should be in DD.MM.YYYY format"
  exit 1
fi

if ! [[ "$end" =~ ^[0-9]{2}\.[0-9]{2}\.[0-9]{4}$ ]]; then
  echo "end date should be in DD.MM.YYYY format"
  exit 1
fi

# flip DD.MM.YYYY to YYYY-MM-DD so git can read it
start_git="${start:6:4}-${start:3:2}-${start:0:2}"
end_git="${end:6:4}-${end:3:2}-${end:0:2}"

# print the table header
echo "Period: $start-$end"
printf "%-15s %s\n" "AUTHOR" "COMMITS"

# get commit counts per author and print each row
git shortlog -sn HEAD --since="$start_git 00:00:00" --until="$end_git 23:59:59" | while read -r count author; do
  printf "%-15s %s\n" "$author" "$count"
done
