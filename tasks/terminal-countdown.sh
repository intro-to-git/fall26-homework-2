#!/usr/bin/env bash

# Terminal Count Down (issue #22)
# Counts down from a number once per second and prints "GO" at zero.

# Usage: ./countdown.sh <number>   (number must be at least 3)

MIN_COUNT=3

if [ $# -ne 1 ]; then
    echo "Usage: $0 <number>"
    exit 1
fi

if [[ ! "$1" =~ ^[1-9][0-9]*$ ]]; then
    echo "Error: '$1' is not a valid positive whole number"
    exit 1
fi

count=$1

if [ "$count" -lt "$MIN_COUNT" ]; then
    echo "Error: the countdown must start from at least $MIN_COUNT"
    exit 1
fi

for (( i = count; i > 0; i-- )); do
    echo "$i"
    sleep 1
done

echo "GO"