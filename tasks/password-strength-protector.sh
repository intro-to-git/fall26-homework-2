#!/usr/bin/env bash

# Password Strength Checker (issue #21)
# Scores a password on length, digits, symbols and case, then prints a verdict.

# Usage: ./password-strength.sh

MIN_LENGTH=8

read -r -s -p "Password: " password
echo

if [ -z "$password" ]; then
    echo "Error: password cannot be empty"
    exit 1
fi

score=0
missing=()

if [[ "$password" =~ [[:lower:]] ]]; then
    score=$(( score + 1 ))
else
    missing+=("no lowercase")
fi

if [[ "$password" =~ [[:upper:]] ]]; then
    score=$(( score + 1 ))
else
    missing+=("no uppercase")
fi

if [[ "$password" =~ [[:digit:]] ]]; then
    score=$(( score + 1 ))
else
    missing+=("no digits")
fi

if [[ "$password" =~ [^[:alnum:]] ]]; then
    score=$(( score + 1 ))
else
    missing+=("no symbols")
fi

if [ "${#password}" -ge "$MIN_LENGTH" ]; then
    score=$(( score + 1 ))
else
    missing+=("short")
fi

if [ "$score" -le 2 ]; then
    verdict="WEAK"
elif [ "$score" -le 4 ]; then
    verdict="MEDIUM"
else
    verdict="STRONG"
fi

reasons=""
for reason in "${missing[@]}"; do
    reasons+="${reasons:+, }$reason"
done

if [ -n "$reasons" ]; then
    echo "Score: $score/5, $verdict ($reasons)"
else
    echo "Score: $score/5, $verdict"
fi