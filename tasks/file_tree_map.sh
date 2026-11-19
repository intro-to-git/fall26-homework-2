#!/bin/bash

# counters for files and directories
f=0
d=0

# function that prints the files and folders inside a directory
show() {
    local folder=$1
    local level=$2
    local max=$3
    local item
    local name
    local space
    local i

    # loop through everything in the current folder
    for item in "$folder"/*
    do
        # skip if the folder is empty
        if [ ! -e "$item" ]; then
            continue
        fi

        # get just the file or folder name
        name=$(basename "$item")
        space=""

        # add spaces based on how deep we are
        for ((i=0; i<level; i++))
        do
            space="$space    "
        done

        # check if the item is a folder or a file
        if [ -d "$item" ]; then
            echo "${space}├── $name"
            d=$((d + 1))

            # go inside the folder if we haven't reached max depth
            if [ "$level" -lt "$max" ]; then
                show "$item" $((level + 1)) "$max"
            fi
        else
            echo "${space}├── $name"
            f=$((f + 1))
        fi
    done
}

# ask the user for the folder and depth
echo "Enter folder:"
read folder

echo "Enter depth:"
read max

# make sure the folder exists before running
if [ -d "$folder" ]; then
    echo "."
    show "$folder" 0 "$max"
    echo "$f files, $d dirs"
else
    echo "Folder not found!"
fi
