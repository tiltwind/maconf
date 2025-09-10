# clash simple guide

## 购买代理服务

购买代理服务, 比如 [speedcat](https://speedcat-aff.com/auth/register?code=59n8)

购买后获得 clash 订阅链接。

## 安装使用
```bash
# 安装
go install github.com/Dreamacro/clash@latest
go install github.com/MerlinKodo/clash-rev@latest

# 默认配置目录为 ~/.config/clash

# 购买代理服务并下载配置
curl --output ~/.config/clash/config.yaml <link>

# 启动 clash
nohup clash &

# 关闭 clash
ps aux | grep -v grep| grep "clash" | awk '{print $2}' | xargs  kill -9

# 配置代理
export https_proxy=http://127.0.0.1:7890 http_proxy=http://127.0.0.1:7890 all_proxy=socks5://127.0.0.1:7890

# 然后你就可以上网冲浪了
```

## macos 命令行设置代理

```bash
# 命令来查看所有网络服务的名称, 一般是 Wi-Fi
networksetup -listallnetworkservices

# 设置代理
sudo networksetup -setwebproxy Wi-Fi 127.0.0.1 7890
sudo networksetup -setsecurewebproxy Wi-Fi 127.0.0.1 7890
sudo networksetup -setsocksfirewallproxy Wi-Fi 127.0.0.1 7890


# 查看代理
networksetup -getwebproxy Wi-Fi
networksetup -getsecurewebproxy Wi-Fi
networksetup -setsocksfirewallproxy Wi-Fi

# 关闭代理
sudo networksetup -setwebproxystate Wi-Fi off
sudo networksetup -setsecurewebproxystate Wi-Fi off
sudo networksetup -setsocksfirewallproxy Wi-Fi off
```

## Run Clash as a Service
```bash
# Copy Clash binary to /usr/local/bin and configuration files to /etc/clash:
cp clash /usr/local/bin
cp config.yaml /etc/clash/
cp Country.mmdb /etc/clash/
```

Create the systemd configuration file at /etc/systemd/system/clash.service:
```ini
[Unit]
Description=Clash daemon, A rule-based proxy in Go.
After=network-online.target

[Service]
Type=simple
Restart=always
ExecStart=/usr/local/bin/clash -d /etc/clash

[Install]
WantedBy=multi-user.target
```

```bash
# After that you're supposed to reload systemd:
systemctl daemon-reload

# Launch clashd on system startup with:
systemctl enable clash

# Launch clashd immediately with:
systemctl start clash

# Check the health and logs of Clash with:
systemctl status clash
journalctl -xe
```

## ref
- https://dreamacro.github.io/clash/introduction/getting-started.html
