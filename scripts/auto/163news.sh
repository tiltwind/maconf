#!/bin/bash

# Setup environment variables for Cron
export PATH="/Users/hk/.nvm/versions/node/v22.20.0/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
export HOME="/Users/hk"

# Setup logging
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${SCRIPT_DIR}/163news.log"
# Redirect stdout and stderr to the log file
exec >> "$LOG_FILE" 2>&1

echo "=================================================="
echo "Script started at $(date)"

# Script to fetch news from 163.com using Claude and push to Feishu

# Check if Webhook ID is provided
if [ -z "$1" ]; then
    echo "Error: Feishu Webhook ID is required as the first argument."
    echo "Usage: $0 <webhook_id>"
    exit 1
fi

WEBHOOK_ID="$1"

# Source the common function
source "${SCRIPT_DIR}/claude_code_web_parser_and_notify.sh"

# 1. Define the prompt for Claude
# We ask Claude to fetch the page and extract news.
# We use --dangerously-skip-permissions to allow tool use (like curl/bash) without interactive approval.
PROMPT="Please analyze https://www.163.com/ and extract the titles and urls of the top 10 latest news articles. Return ONLY the list, numbered 1-10. Do not include any other conversational text.Remove useless query string, like clickfrom, etc."

# 2. Call the function
claude_web_parser_and_notify "$WEBHOOK_ID" "$PROMPT"
