#!/bin/bash

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Parse command line arguments for verbose mode
VERBOSE=false
while getopts ":v" option; do
  case $option in
    v) VERBOSE=true ;;
    *) echo "Usage: $0 [-v]" ;;
  esac
done

# Get user input for target domain, OOS patterns, Jaeles severity level, subdomains file, program name, and signature path
read -p "Enter the target domain: " TARGET_DOMAIN
read -p "Enter comma-separated OOS patterns: " OOS_PATTERNS
read -p "Enter Jaeles severity level (e.g., 1, 2, 3, ...): " SEVERITY_LEVEL
read -p "Enter the path to the subdomains file (leave empty to use subfinder and dnsx): " SUBDOMAINS_FILE
read -p "Enter the bug bounty program name: " PROGRAM_NAME
read -p "Enter the path to Jaeles signatures (leave empty to use default: /home/kali/jaeles-signatures): " SIGNATURES_PATH

# Use default signatures path if none provided
if [[ -z "$SIGNATURES_PATH" ]]; then
  SIGNATURES_PATH="/home/kali/jaeles-signatures"
fi

# Ensure Jaeles signatures directory exists
if [[ ! -d "$SIGNATURES_PATH" ]]; then
  echo -e "${RED}Jaeles signatures directory not found. Please ensure it exists at ${SIGNATURES_PATH}.${NC}"
  exit 1
fi

# Show the custom header value
CUSTOM_HEADER="X-Bug-bounty: insert-username-here@${PROGRAM_NAME}"
echo -e "${YELLOW}Custom header for Jaeles scans: ${CUSTOM_HEADER}${NC}"

# Temporary files to store subdomains and live URLs
SUBDOMAINS=$(mktemp)
LIVE_URLS=$(mktemp)

# Discover and validate subdomains
if [[ -z "$SUBDOMAINS_FILE" ]]; then
  echo -e "${GREEN}Running subfinder to discover subdomains...${NC}"
  subfinder -d "$TARGET_DOMAIN" | anew > "$SUBDOMAINS"
else
  echo -e "${YELLOW}Using provided subdomains file: $SUBDOMAINS_FILE${NC}"
  cat "$SUBDOMAINS_FILE" | anew > "$SUBDOMAINS"
fi

echo -e "${BLUE}Subdomains discovered:${NC}"
cat "$SUBDOMAINS"

# Validate live URLs
echo -e "${GREEN}Validating live URLs using httpx...${NC}"
cat "$SUBDOMAINS" | httpx -silent | anew > "$LIVE_URLS"

echo -e "${BLUE}Live URLs validated:${NC}"
cat "$LIVE_URLS"

# Scan live URLs with Jaeles
echo -e "${GREEN}Running Jaeles scans on live URLs...${NC}"
while read -r url; do
  cmd="jaeles scan -L $SEVERITY_LEVEL -c 20 -s $SIGNATURES_PATH/* -u $url -H \"$CUSTOM_HEADER\" -o ${TARGET_DOMAIN}_jaeles_results.txt"
  echo -e "${BLUE}Running: $cmd${NC}"
  eval "$cmd"
done < "$LIVE_URLS"

# Generate the Jaeles report
echo -e "${GREEN}Generating the Jaeles report...${NC}"
jaeles report -o /home/kali/scanned/out --title 'Verbose Report' --sverbose

# Clean up
rm "$SUBDOMAINS"
rm "$LIVE_URLS"

echo -e "${GREEN}Scanning completed. Results saved to ${TARGET_DOMAIN}_jaeles_results.txt and report generated at /home/kali/scanned/out.${NC}"
