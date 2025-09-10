<!---
markmeta_author: wongoo
markmeta_date: 2019-07-17
markmeta_title: aria2 下载工具
markmeta_categories: app
markmeta_tags: aria2,download
-->

# aria2 下载工具

## install
```
brew install aria2

cd ~
mkdir .aria2
cd .aria2
touch aria2.conf

# --------- download source
# brew install libxml2
# sudo ln -s /usr/local/homebrew/Cellar/libxml2/2.9.9_2/include/libxml2/libxml /usr/local/include/libxml
# curl -v -L -C - -O https://github.com/aria2/aria2/releases/download/release-1.34.0/aria2-1.34.0.tar.gz

```

## aria2.conf

```
#用户名
#rpc-user=user
#密码
#rpc-passwd=passwd
#上面的认证方式不建议使用,建议使用下面的token方式
#设置加密的密钥
#rpc-secret=token
#允许rpc
enable-rpc=true
#允许所有来源, web界面跨域权限需要
rpc-allow-origin-all=true
#允许外部访问，false的话只监听本地端口
rpc-listen-all=true
#RPC端口, 仅当默认端口被占用时修改
#rpc-listen-port=6800
#最大同时下载数(任务数), 路由建议值: 3
max-concurrent-downloads=5
#断点续传
continue=true
#同服务器连接数
max-connection-per-server=5
#最小文件分片大小, 下载线程数上限取决于能分出多少片, 对于小文件重要
min-split-size=10M
#单文件最大线程数, 路由建议值: 5
split=10
#下载速度限制
max-overall-download-limit=0
#单文件速度限制
max-download-limit=0
#上传速度限制
max-overall-upload-limit=0
#单文件速度限制
max-upload-limit=0
#断开速度过慢的连接
#lowest-speed-limit=0
#验证用，需要1.16.1之后的release版本
#referer=*
#文件保存路径, 默认为当前启动位置
dir=/Users/xxx/Downloads
#文件缓存, 使用内置的文件缓存, 如果你不相信Linux内核文件缓存和磁盘内置缓存时使用, 需要1.16及以上版本
#disk-cache=0
#另一种Linux文件缓存方式, 使用前确保您使用的内核支持此选项, 需要1.15及以上版本(?)
#enable-mmap=true
#文件预分配, 能有效降低文件碎片, 提高磁盘性能. 缺点是预分配时间较长
#所需时间 none < falloc ? trunc « prealloc, falloc和trunc需要文件系统和内核支持
file-allocation=prealloc
```

## start

```bash
aria2c --conf-path="~/.aria2/aria2.conf" -D
```

## chrome plugin

```
https://chrome.google.com/webstore/search/baiduexporter?h1=zh
```

## Example
```
# Download from WEB:
$ aria2c http://example.org/mylinux.iso

# Download from 2 sources:
$ aria2c http://a/f.iso ftp://b/f.iso

# Download using 2 connections per host:
$ aria2c -x2 http://a/f.iso

# BitTorrent:
$ aria2c http://example.org/mylinux.torrent

# BitTorrent Magnet URI:
$ aria2c 'magnet:?xt=urn:btih:248D0A1CD08284299DE78D5C1ED359BB46717D8C'

# Metalink:
$ aria2c http://example.org/mylinux.metalink

# Download URIs found in text file:
$ aria2c -i uris.txt
```

## Reference

- https://aria2.github.io/

