#!/bin/bash

# Setup environment variables for Cron
export PATH="/Users/hk/.nvm/versions/node/v22.20.0/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Users/hk/.local/bin:$PATH"
export HOME="/Users/hk"

# Setup logging
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${SCRIPT_DIR}/freelancerresearch.log"
# Redirect stdout and stderr to the log file
exec >> "$LOG_FILE" 2>&1

echo $ANTHROPIC_API_KEY
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
PROMPT="作为一个洞悉AI发展的分析师, 收集【AI进化】、【AI创新产品】、【Agent能力进化】、【Agent团队】等行业新闻和信息, 分类整理，最后提出洞见建议； 相关资料要提供标题和链接；总体字数不超过300字；"

# 2. Call the function
claude_web_parser_and_notify "$WEBHOOK_ID" "$PROMPT"
