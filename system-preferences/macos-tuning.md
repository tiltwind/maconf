<!---
markmeta_author: wongoo
markmeta_date: 2019-07-17
markmeta_title: macOS tunning
markmeta_categories: perferences
markmeta_tags: tunning
-->

# macOS tunning

## 常用设置

```
net.inet.ip.portrange.first: 10000
net.inet.ip.portrange.hifirst: 10000
net.inet.tcp.msl=1000

kern.ipc.maxsockbuf=8000000
net.inet.tcp.sendspace=65536
net.inet.tcp.recvspace=65536
```

## net.inet.tcp.delayed_ack
TCP 协定有一个特性，就是当收到客户端的资料时，会传回一个 ACK (acknowledgement) 的封包，以确认已收到资料。
其他的网络服务，例如，WWW、SMTP、POP3 等也都具有这种特性。
在高速网络和低负载的情况下会稍微提高效能;但在网络连接较差的情况下对方电脑得不到应答反而会降低效能。
```
net.inet.tcp.delayed_ack=0
default : 3
```

## kern.ipc.maxsockbuf
这是用来设定系统最大可以开启的 socket 数目。如果您的服务器会提供大量的 FTP 服务，而且常快速的传输一些小档案，您也许会发现常传输到一半就中断。因为 FTP 在传输档案时，每一个档案都必须开启一个 socket 来传输，但关闭 socket 需要一段时间，如果传输速度很快，而档案又多，则同一时间所开启的 socket 会超过原本系统所许可的值，这时我们就必须把这个值调大一点。除了 FTP 外，也许有其他网络程式也会有这种问题。
```
kern.ipc.maxsockbuf=8000000
default: 262144
```

## net.inet.tcp.sendspace 及 net.inet.tcp.recvspace
这二个选项分别控制了网络 TCP 连线所使用的传送及接收暂存区的大小。
默认的传送暂存区为 32K，而接收暂存区为 64K。如果需要加速 TCP 的传输，可以将这二个值调大一点，但缺点是太大的值会造成系统核心占用太多的内存。
如果我们的机器会同时服务数百或数千个网络连线，那么这二个选项最好维持默认值，否则会造成系统核心内存不足。
但如果我们使用的是 gigabite 的网络，将这二个值调大会有明显效能的提升。
传送及接收的暂存区大小可以分开调整，例如，假设我们的系统主要做为网页服务器，我们可以将接收的暂存区调小一点，并将传送的暂存区调大，如此一来，我们就可以避免占去太多的核心内存空间。
```
default=
net.inet.tcp.recvspace: 32768
net.inet.tcp.sendspace: 32768
```

参考:http://www.apple.com/support/downloads/broadbandtuner10.html

和上面的 kern.ipc.maxsockbuf 搭配,可以增加网络传输的速度:
```
kern.ipc.maxsockbuf=8000000
net.inet.tcp.sendspace=65536
net.inet.tcp.recvspace=65536
```

## kern.maxproc 及 kern.maxprocperuid
- 允许系统执行最多的进程(processes) : kern.maxproc=2048
- 允许使用者执行最多的进程(processes): kern.maxprocperuid=500

```
default=
kern.maxproc = 532
kern.maxprocperuid = 100
```

## net.inet.ip.portrange.* 
是用来控制 TCP 及 UDP 所使用的 port 范围，这个范围被分成三个部份，低范围、默认范围、及高范围。
让我们看一下目前各范围 port 的情形：

```
net.inet.ip.portrange.first: 49152
net.inet.ip.portrange.hifirst: 49152
net.inet.ip.portrange.hilast: 65535
net.inet.ip.portrange.last: 65535
net.inet.ip.portrange.lowfirst: 1023
net.inet.ip.portrange.lowlast: 600

default=
net.inet.ip.portrange.first: 49152
net.inet.ip.portrange.last: 65535
```

## kern.ipc.somaxconn
这个选项控制了 TCP 连线等候区最多可以等待的连线数量，其默认值为 128，不过这个值对于一台忙碌的服务器而言可能小了点。例如大型的网页服务器、邮件服务器，我们可以将它设为 1024。要注意的是在一些网络服务的程式中，如 Apache 及 sendmail 也有自己的等待数量设定，我们可能也要在那些软件上做一些设定才会让 kern.ipc.somaxconn 发生作用。将这个选项的值调大一点还有一个好处，就是在面对 Denial of service 的攻击时，有较好的防卫能力。
```
default: 28
```

## kern.maxfiles
这个选项控制了系统中支援最多开启的档案数量，这个值通常是几千个档，但对于一台忙碌的数据库系统或是会开启许多档案的服务器而言，我们可以将它调高为一、二万。
```
default: 2288
```

## net.inet.tcp.always_keepalive
设置为1会帮助系统清除没有正常中断的TCP连线,这增加了一些网络频宽的使用;但是当一些死掉的连线最终还是能被识别并清除。

default: 0

## net.inet.tcp.msl
这项参数在定义最大的区段Life(Maximun Segment Lift),主要是防止DoS(Denial of Service的简称，即拒绝服务)攻击。
也就是当骇客发出一连串SYN封包,而我们的电脑要回应一个SYN-ACK封包,然后等对方(骇客)回应ACK封包,
由于骇客并不产生任何ACK封包给我们的电脑，因此我们的电脑伫列里面会暂存大量的SYN-ACK封包，这些封包必须等到收到对方的ACK封包或是超过逾时时间之后才会被移除。如此我们的电脑会因为充满了SYN-ACK封包而造成无法再处理其他使用者的服务与要求。
在FreeBSD是设定为30000,如想要有强大DoS保护则必须设定更小的值。

```
default : 15000
```
