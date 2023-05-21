# clash simple guide

## How Clash works

![](https://dreamacro.github.io/clash/assets/connection-flow.a72146ab.png)

## install
```bash
go install github.com/Dreamacro/clash@latest
clash -f ./config.yaml
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
