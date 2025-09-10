
```bash
brew install dnsmasq

mkdir /usr/local/etc/

vi /usr/local/etc/dnsmasq.conf

address=/example.localhost/127.0.0.1
address=/wognoo.hktrd.cn/192.168.15.17
listen-address=127.0.0.1

sudo brew services stop dnsmasq
sudo brew services start dnsmasq

```
