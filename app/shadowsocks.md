# Shadowsocks

## 1. install shadowsocks server

buy a ECS server located in US, and install shadowsocks server:

```
wget --no-check-certificate -O shadowsocks-all.sh https://raw.githubusercontent.com/teddysun/shadowsocks_install/master/shadowsocks-all.sh
chmod +x shadowsocks-all.sh
 ./shadowsocks-all.sh 2>&1 | tee shadowsocks-all.log
```

执行命令后，会提示输入源码语言，密码、端口、及加密方式等。（笔者这里端口使用6789；源码选择的是go语言；加密方式我这里选择aes-256-cfb；）

VPC安全组开放6789端口（根据自己使用的端口）

配置linux server防火墙开发6789端口

创建shadowsocks配置文件`/etc/shadowsocks-go/config.json`:
```
{
    "server":"0.0.0.0",
    "server_port":6789,
    "local_port":1080,
    "password":"my-ss-password",
    "method":"aes-256-cfb",
    "timeout":300
}
```

启动server: `/usr/bin/shadowsocks-server -c /etc/shadowsocks-go/config.json`


## 2. install client

download client [ShadowsocksX-NG](https://github.com/shadowsocks/ShadowsocksX-NG/releases/) 
or [ShadowsocksX-NG-R](https://github.com/qinyuhang/ShadowsocksX-NG-R/releases)

unzip and copy to dir /Applications, then start it.

Add a SS server, then `Turn Shadowsocks On`.


## 3. user rule for pac

```
! 用户自定义规则语法:
!
!   与gfwlist相同，使用AdBlock Plus过滤规则( http://adblockplus.org/en/filters )
!
!     1. 通配符支持，如 *.example.com/* 实际书写时可省略*为 .example.com/
!     2. 正则表达式支持，以\开始和结束， 如 \[\w]+:\/\/example.com\\
!     3. 例外规则 @@，如 @@*.example.com/* 满足@@后规则的地址不使用代理
!     4. 匹配地址开始和结尾 |，如 |http://example.com、example.com|分别表示以http://example.com开始和以example.com结束的地址
!     5. || 标记，如 ||example.com 则http://example.com、https://example.com、ftp://example.com等地址均满足条件
!     6. 注释 ! 如 ! Comment
!
!   配置自定义规则时需谨慎，尽量避免与gfwlist产生冲突，或将一些本不需要代理的网址添加到代理列表
!
!   规则优先级从高到底为: user-rule > user-rule-from > gfwlist
!
! Tip: 
!   如果生成的是PAC文件，用户定义规则先于gfwlist规则被处理
!   因此可以在这里添加例外或常用网址规则，或能减少在访问这些网址进行查询的时间, 如下面的例子
!
!   但其它格式如wingy, dnsmasq则无此必要, 例外规则将被忽略, 所有规则将被排序
! 

@@sina.com
@@163.com

twitter.com
youtube.com
||google.com
||wikipedia.org
```
