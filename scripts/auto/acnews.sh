#!/bin/bash

# Setup environment variables for Cron
export PATH="/Users/hk/.nvm/versions/node/v22.20.0/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
export HOME="/Users/hk"

# Setup logging
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${SCRIPT_DIR}/acnews.log"
# Redirect stdout and stderr to the log file
exec >> "$LOG_FILE" 2>&1

echo "=================================================="
echo "Script started at $(date)"

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
# We ask Claude to use chrome-devtools MCP to open the page and extract news.
# We use --dangerously-skip-permissions to allow tool use without interactive approval.
PROMPT="Use the chrome-devtools MCP to open https://hub.baai.ac.cn/ in the browser. extract the titles and URLs of the top 1-3 latest news articles or posts. Return ONLY a numbered list (1-3) with title and URL for each item. Do not include any other conversational text. Url should belong the domain https://hub.baai.ac.cn/."

# 2. Call the function
claude_web_parser_and_notify "$WEBHOOK_ID" "$PROMPT"
