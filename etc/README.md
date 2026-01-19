
# 配置引用启动环境变量

create `~/Library/LaunchAgents/claudeapp.env.plist`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>user.claudeapp.env</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>-c</string>
        <string>env https_proxy=http://127.0.0.1:7890 http_proxy=http://127.0.0.1:7890 all_proxy=socks5://127.0.0.1:7890 open -n "/Applications/Claude.app"</string>
    </array>
    <key>RunAtLoad</key>
    <false/>
</dict>
</plist>
``` 

exec: `launchctl load ~/Library/LaunchAgents/claudeapp.env.plist`

