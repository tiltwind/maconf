
# config maxfiles for macOS

## 查看

命令: `ulimit -a`

```shell
> ulimit -a
-t: cpu time (seconds)              unlimited
-f: file size (blocks)              unlimited
-d: data seg size (kbytes)          unlimited
-s: stack size (kbytes)             8192
-c: core file size (blocks)         0
-v: address space (kbytes)          unlimited
-l: locked-in-memory size (kbytes)  unlimited
-u: processes                       709
-n: file descriptors                4864
```

查看当前maxfiles配置:
```shell
> launchctl limit maxfiles
maxfiles    256      unlimited
```
- 第1个数字 256 是 soft limit, 过低需要设置一下
- 第2个数字 unlimited 是 hard limit


## 设置

### 临时设置
```
sudo sysctl -w kern.maxfiles=2000000
sudo sysctl -w kern.maxfilesperproc=1000000

# 以上两句可以统一为一句
sudo launchctl limit maxfiles 1000000 2000000
sudo ulimit -n 1000000 # 此值不能大于kern.maxfilesperproc
```

### 永久设置方法（一）

文件/etc/sysctl.conf添加:
```
kern.maxfiles=2000000
kern.maxfilesperproc=1000000
```

文件 /etc/profile 添加: ulimit -n 1000000

### 永久设置方式（二）

maxfiles:
```
> sudo vi /Library/LaunchDaemons/limit.maxfiles.plist

<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>Label</key>
    <string>limit.maxfiles</string>
    <key>ProgramArguments</key>
    <array>
      <string>launchctl</string>
      <string>limit</string>
      <string>maxfiles</string>
      <string>1000000</string>
      <string>2000000</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>ServiceIPC</key>
    <false/>
  </dict>
</plist>
```

change permissian and reload:
```
sudo chown root:wheel /Library/LaunchDaemons/limit.maxfiles.plist
sudo launchctl load -w /Library/LaunchDaemons/limit.maxfiles.plist
```

重启系统!



