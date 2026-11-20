#!/usr/bin/env bash

# Find all empty subdirectories (excluding the current folder itself)
mapfile -t dirs < <(find . -mindepth 1 -depth -type d -empty)

# Stop early if nothing was found
if [[ ${#dirs[@]} -eq 0 ]]; then
  echo "No empty directories found."
  exit 0
fi

# Show the directories and ask for confirmation
printf '%s\n' "${dirs[@]}"
read -r -p "Remove ${#dirs[@]} empty directories? [y/N] " answer

# Delete and report the count
if [[ "$answer" =~ ^[Yy]$ ]]; then
  rmdir "${dirs[@]}"
  echo "Removed ${#dirs[@]} empty directories."
fi

