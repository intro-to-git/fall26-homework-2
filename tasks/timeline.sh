#!/bin/bash
# Usage: ./tasks/timeline.sh <filename>
if [ $# -ne 1 ]; then echo "Usage: $0 <filename>" >&2; exit 1; fi
file="$1"
echo "# Timeline: $file" > timeline.md
git log --follow --date=short --format="- %ad %an  %s" -- "$file" >> timeline.md
