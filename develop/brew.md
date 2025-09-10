<!---
markmeta_author: wongoo
markmeta_date: 2019-07-17
markmeta_title: brew 
markmeta_categories: app
markmeta_tags: brew
-->

# brew

brew: 是从下载源码解压然后 ./configure && make install ，同时会包含相关依存库。并自动配置好各种环境变量，而且易于卸载。
这个对程序员来说简直是福音，简单的指令，就能快速安装和升级本地的各种开发环境。

brew cask: 是已经编译好了的应用包 （.dmg/.pkg），仅仅是下载解压，放在统一的目录中（/opt/homebrew-cask/Caskroom），省掉了自己去下载、解压、拖拽（安装）等蛋疼步骤，
同样，卸载相当容易与干净。这个对一般用户来说会比较方便，包含很多在 AppStore 里没有的常用软件。

