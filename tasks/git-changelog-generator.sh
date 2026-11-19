#!/bin/env bash

# Usage: ./tasks/changelog.sh <tag1> <tag2>
# Generates CHANGELOG.md with the commits between two tags,
# grouped by commit type (feat / fix)

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <tag1> <tag2>"
  exit 1
fi

TAG1="$1"
TAG2="$2"

print_section() {
  local type="$1"
  local heading=""

  case "$type" in
    feat ) heading="Features" ;;
    fix ) heading="Fixes" ;;
  esac

  echo "## $heading" >> CHANGELOG.md

  git log "$TAG1..$TAG2" --pretty=tformat:"%s|%an|%ad" --date=short | grep -e "^${type}[(:]" | while read -r line; do
    subject=$(echo "$line" | cut -d'|' -f1)
    author=$(echo "$line" | cut -d'|' -f2)
    day=$(echo "$line" | cut -d'|' -f3)
    msg=$(echo "$subject" | cut -d':' -f2- | cut -c2-)

    echo "- $msg ($author, $day)" >> CHANGELOG.md
  done
}

echo "# Changes between $TAG1 to $TAG2" > CHANGELOG.md
print_section feat
print_section fix

