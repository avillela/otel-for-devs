#!/bin/bash

# Script to call the rolldice endpoint once per minute

URL="http://localhost:8008/rolldice"

while true; do
    echo "$(date): Calling rolldice"
    curl -s "$URL"
    echo ""
    sleep 60
done
