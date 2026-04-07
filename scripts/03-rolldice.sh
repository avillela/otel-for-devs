#!/bin/bash

# Script to call the rolldice endpoint once per minute

URL="http://localhost:8080/rolldice"

while true; do
    echo "$(date): Calling rolldice"
    curl -s "$URL"
    echo ""
    sleep 5
done
