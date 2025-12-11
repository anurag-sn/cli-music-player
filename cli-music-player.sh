#!/bin/bash

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- Dependency Check ---
for cmd in mpv yt-dlp jq; do
    if ! command -v $cmd &> /dev/null; then
        echo -e "${RED}Error: $cmd is not installed.${NC}"
        echo "Install it with: sudo apt install $cmd"
        exit 1
    fi
done

# --- 1. Get Search Query ---
clear
echo -e "${BLUE}========================================${NC}"
echo -e "${CYAN}   🎵  CLI MUSIC STREAMING  🎵${NC}"
echo -e "${BLUE}========================================${NC}"

if [ -z "$1" ]; then
    echo -e -n "${YELLOW}Search Song/Artist: ${NC}"
    read QUERY
else
    QUERY="$*"
fi

echo -e "\n${GREEN}🔍 Searching YouTube for '${QUERY}'...${NC}"

SEARCH_FILE=$(mktemp)
yt-dlp "ytsearch5:$QUERY" --dump-json --flat-playlist --no-warnings > "$SEARCH_FILE" 2>/dev/null

if [ ! -s "$SEARCH_FILE" ]; then
    echo -e "${RED}❌ No results found.${NC}"
    rm "$SEARCH_FILE"
    exit 1
fi

# --- 3. Display Results ---
echo -e "${BLUE}----------------------------------------${NC}"
# Read the file line by line (each line is a JSON object)
i=1
declare -a TITLES
declare -a IDS

while read -r line; do
    # Extract Title and ID using jq
    TITLE=$(echo "$line" | jq -r '.title')
    ID=$(echo "$line" | jq -r '.id')
    UPLOADER=$(echo "$line" | jq -r '.uploader')

    TITLES[$i]="$TITLE"
    IDS[$i]="$ID"

    echo -e "${CYAN}[$i]${NC} ${TITLE} ${YELLOW}($UPLOADER)${NC}"
    ((i++))
done < "$SEARCH_FILE"
echo -e "${BLUE}----------------------------------------${NC}"

# --- 4. User Selection ---
echo -e "${YELLOW}Enter numbers to play (e.g. '1 3' or Enter for ALL):${NC}"
read SELECTION

QUEUE_URLS=""

if [ -z "$SELECTION" ]; then
    # Play All
    for ((j=1; j<i; j++)); do
        QUEUE_URLS="$QUEUE_URLS https://www.youtube.com/watch?v=${IDS[$j]}"
    done
else
    # Play Selected
    for num in $SELECTION; do
        if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -lt "$i" ]; then
            QUEUE_URLS="$QUEUE_URLS https://www.youtube.com/watch?v=${IDS[$num]}"
        fi
    done
fi

# Cleanup
rm "$SEARCH_FILE"

if [ -z "$QUEUE_URLS" ]; then
    echo -e "${RED}Invalid selection.${NC}"
    exit 1
fi

# --- 5. Play with MPV ---
clear
echo -e "${GREEN}🎧 Starting Player...${NC}"
echo -e "${BLUE}Controls:${NC} [Space]=Pause | [←/→]=Seek | [Enter]=Next | [q]=Quit"
echo -e "${BLUE}========================================${NC}"

# --term-osd-bar: Shows a progress bar in the terminal
# --term-playing-msg: Shows the song name
mpv --no-video --term-osd-bar --term-osd-bar-chars="[#= ]" --term-playing-msg="Now Playing: \${media-title}" $QUEUE_URLS
