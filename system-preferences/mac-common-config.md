# mac common config

```bash
# 修改主机名
sudo scutil --set HostName xxxxx

# 修改共享名称
sudo scutil --set ComputerName xxxxx
```

## brew 加速

替换成国内源:

```bash
# https://github.com/Homebrew/brew.git
git -C "$(brew --repo)" remote set-url origin https://mirrors.ustc.edu.cn/brew.git

# https://github.com/Homebrew/homebrew-core.git
git -C "$(brew --repo homebrew/core)" remote set-url origin https://mirrors.ustc.edu.cn/homebrew-core.git

# https://github.com/Homebrew/homebrew-cask.git
git -C "$(brew --repo homebrew/cask)" remote set-url origin https://mirrors.ustc.edu.cn/homebrew-cask.git

# 替换Homebrew Bottles源
echo 'export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles' >> ~/.zshrc

cd ~
source ~/.zshrc

# 再更新一下试试看效果 注意网速 应该可以跑满
brew update -v
```

## 常见技巧

- 重启Mac，按住Option键进入启动盘选择模式
- 按⌘ +R进入Recovery模式

## 重制权限

```bash
# 屏幕权限重置,之前分配给应用的权限都将失效，需要重新配置
# 有时系统分配权限不生效，采用这种重新分配的方式可以解决.
tccutil reset ScreenCapture  

# 辅助功能重置 
tccutil reset Accessibility
```
