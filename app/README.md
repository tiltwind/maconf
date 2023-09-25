<!---
markmeta_author: wongoo
markmeta_date: 2019-07-17
markmeta_title: mac 应用列表
markmeta_categories: app
markmeta_tags: app
-->

# install apps

## basic apps

- [git](https://git-scm.com/download/mac), add `~/.gitconfig`, copy old ssh keys to `~/.ssh`
  - [A syntax-highlighting pager for git, diff, and grep output](https://dandavison.github.io/delta/introduction.html)
- [iterm2](iterm2.md), see [install steps](vim/vim-install.md)
  - [vim](vim/)
  - nvim: `sudo port install neovim`, add `~/.config/nvim/init.vim` following [FAQ](https://github.com/neovim/neovim/wiki/FAQ)
- xcode-select --install
- [macport](https://www.macports.org/install.php)
- chrome
- firefox
- xunlei
- clashx
- [sublime text](https://www.sublimetext.com/)

- ~~[homebrew](https://docs.brew.sh/Installation),brew不建议使用,更建议使用macport~~
- ~~shadowsocks~~

## apps for management
- recess
- Tencent Lemon Lite: 腾讯系统清理优化软件，免费
- cleanmydrive : 系统清理软件，收费


## apps for development
- sdkman: https://sdkman.io/install
```bash
curl -s "https://get.sdkman.io" | bash`
sdk install java
sdk install maven
```

- jdk: [openjdk](https://jdk.java.net/) 
- golang: [check version](https://github.com/golang/go/releases), [install guide](https://github.com/wongoo/doc/blob/master/lang/go/go-install.md)
- python: `brew install python3`
- rust
- npm
- goland
- clion
- inteliJ IDEA
- postman
- navicat premium： 收费
- Beekeeper Studio: mysql 客户端，免费
- studio 3T： mongodb客户端
- [maven](https://maven.apache.org/download.cgi)
- [redis](redis/redis.md)
- mongodb
- docker

# apps for office
- wechat
- qq
- lark: 飞书
- dingding: 钉钉
- mingdao: 敏捷工具，看公司需要什么

## apps for document
- 注重效率和体验的笔记软件，个人免费: https://obsidian.md/
- wps
- youdao note
- youdao dict
- kindle: 电子书阅读
- xmind: 思维导图，目前
- 网易邮箱大师
- airmail 3： 邮箱客户端的另一个选择
- KeyKey Typing Tutor: 是一款Mac OS X 上优秀的键盘打字练习工具
- pandoc, 支持markdown 转换操作
```bash
sudo port install pandoc
pandoc --from markdown --to epub3 book.md --output book.epub --toc --epub-cover-image=img/cover.png
pandoc --from markdown --to epub3 战略.md --output 战略.epub --toc --epub-cover-image=/Users/gelnyang/Downloads/strategy.webp
```


## apps for entertaiment
- youku
- iqiyi
- tencent video
- netease music

# tools
- [aria2](aria2.md)
- [sshpass](sshpass.md)
- ngrok, 反向代理工具，完成内网穿透，暴露本地服务的公网访问入口，该工具仅适用于开发测试阶段。https://dashboard.ngrok.com/get-started/setup
- https://tabserve.dev/, 网页版反向代理工具,  A secure & fast HTTPS URL for localhost using your browser as a reverse proxy.



