#!/bin/bash

# Script to ensure files end with a newline
# Usage: ./ensure-newline.sh file1.txt file2.txt ...

set -e

# Function to display usage information
show_usage() {
    echo "Usage: $0 <file1> [file2] [file3] ..."
    echo "Ensures each specified file ends with a newline character."
    echo ""
    echo "Examples:"
    echo "  $0 file.txt"
    echo "  $0 *.txt"
    echo "  $0 file1.txt file2.txt file3.txt"
}

# Check if any arguments were provided
if [ $# -eq 0 ]; then
    echo "Error: No files specified"
    show_usage
    exit 1
fi

# Process each file argument
for file in "$@"; do
    # Check if file exists
    if [ ! -f "$file" ]; then
        echo "Warning: File '$file' does not exist, skipping..."
        continue
    fi
    
    # Check if file is readable
    if [ ! -r "$file" ]; then
        echo "Warning: File '$file' is not readable, skipping..."
        continue
    fi
    
    # Check if file ends with newline using tail
    if [ -s "$file" ] && [ "$(tail -c1 "$file" | wc -l)" -eq 0 ]; then
        echo "Adding newline to '$file'"
        echo "" >> "$file"
    else
        echo "File '$file' already ends with newline or is empty"
    fi
done

echo "Done!" 
