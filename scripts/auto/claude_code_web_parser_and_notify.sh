#!/bin/bash

# Function to parse web content using Claude and notify via Feishu
# Arguments:
#   $1: WEBHOOK_ID - The ID for the Feishu Webhook
#   $2: PROMPT - The prompt to send to Claude
function claude_web_parser_and_notify() {
    local WEBHOOK_ID="$1"
    local PROMPT="$2"

    if [ -z "$WEBHOOK_ID" ]; then
        echo "Error: Feishu Webhook ID is required."
        return 1
    fi

    if [ -z "$PROMPT" ]; then
        echo "Error: Prompt is required."
        return 1
    fi


    export https_proxy=http://127.0.0.1:7890 http_proxy=http://127.0.0.1:7890 all_proxy=socks5://127.0.0.1:7890

    # Execute Claude
    # -p / --print: Print the result to stdout
    # --dangerously-skip-permissions: Allow tools to run without confirmation
    # We pipe to sed to strip ANSI color codes just in case.
    echo "Executing Claude with prompt..."
    NEWS_CONTENT=$(claude --print --dangerously-skip-permissions "$PROMPT" | sed 's/\x1b\[[0-9;]*m//g')

    # Check if we got content
    if [ -z "$NEWS_CONTENT" ]; then
        echo "Error: Failed to retrieve news content from Claude."
        return 1
    fi

    echo "Got news content:"
    echo "$NEWS_CONTENT"

    # Format JSON for Feishu
    # Use jq to safely create the JSON payload
    JSON_PAYLOAD=$(jq -n --arg text "$NEWS_CONTENT" '{msg_type: "text", content: {text: $text}}')

    # Push to Feishu Webhook
    WEBHOOK_URL="https://open.feishu.cn/open-apis/bot/v2/hook/${WEBHOOK_ID}"

    echo "Pushing to Feishu..."
    curl -X POST -H "Content-Type: application/json" \
         -d "$JSON_PAYLOAD" \
         "$WEBHOOK_URL"

    echo -e "\nDone."
}
