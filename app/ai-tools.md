
# claude code

```bash
sudo npm install -g @anthropic-ai/claude-code
sudo npm install -g @musistudio/claude-code-router
```

vi ~/.claude-code-router/config.json, more config see https://github.com/musistudio/claude-code-router: 
```json
{
  "PROXY_URL": "http://127.0.0.1:7890",
  "LOG": true,
  "API_TIMEOUT_MS": 600000,
  "NON_INTERACTIVE_MODE": false,
  "Providers": [
    {
      "name": "deepseek",
      "api_base_url": "https://api.deepseek.com/chat/completions",
      "api_key": "sk-xxx",
      "models": ["deepseek-chat", "deepseek-reasoner"],
      "transformer": {
        "use": ["deepseek"],
        "deepseek-chat": {
          "use": ["tooluse"]
        }
      }
    }
  ],
  "Router": {
    "default": "deepseek,deepseek-chat",
    "background": "deepseek,deepseek-chat",
    "think": "deepseek,deepseek-reasoner",
    "longContext": "deepseek,deepseek-reasoner",
    "longContextThreshold": 60000
  }
}
```

Start Claude Code using the router: `ccr code`


# qwen code
https://github.com/QwenLM/qwen-code

```bash
sudo npm install -g @qwen-code/qwen-code@latest
qwen --version

export OPENAI_API_KEY="xxxx"
export OPENAI_BASE_URL="https://api.deepseek.com"
export OPENAI_MODEL="deepseek-chat"
```
