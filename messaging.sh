#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 \"Input message\" [index]"
    echo "Example: $0 \"Hello\"          # sends to everyone"
    echo "         $0 \"Hello\" <index>  # sends to that index"
    exit 1
fi

MESSAGE="$1"
shift
INDICES=("$@")

if [ ${#INDICES[@]} -eq 0 ]; then
    # Broadcast to all terminals
    who | awk '{print $2}' | while read TTY; do
        if [ -w "/dev/$TTY" ]; then
            echo "$MESSAGE" > "/dev/$TTY"
        fi
    done
else
    # Send to specific session IDs (first column from who)
    for ID in "${INDICES[@]}"; do
            who | awk -v id="$ID" '$1 == id {print $2}' | while read TTY; do
                if [ -n "$TTY" ] && [ -w "/dev/$TTY" ]; then
                        echo "$MESSAGE" > "/dev/$TTY"
                else
                        echo "Unable to write to session ID $ID"
                 fi
         done
    done
fi
