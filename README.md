# my mac config

- [System-preferences](system-preferences)
- [Apps](app)
- [Scripts](scripts)
- [etc](etc)


## useful app in app store

- Tencent Lemon Cleanner (Lite) : Clean up and free up space

## view all app under mac

```bash
system_profiler SPApplicationsDataType|sed -n 's/^ *Location: \(.*\)/\1/p' | sort > apps.txt
```

## experience

1. chrome full screen capture:
- open dev tool: `command + option + i`
- open command tool: `command + shift + p`#
- input `screenshot`, choose the `Capture full size screenshot`


## Application Management

- update all software: `softwareupdate --all --install --force`


## System Control

- restart Mac, then 
	- press `Command-R`：从内建 macOS 恢复系统启动。使用此按键组合来重新安装之前安装在系统上的最新 macOS，或使用 macOS 恢复中的其他 App。
	- press `Option-Command-R`：通过互联网从 macOS 恢复启动。使用此按键组合来重新安装 macOS 并升级到与你 Mac 兼容的最新版本 macOS。
	- press `Option-Shift-Command-R`：通过互联网从 macOS 恢复启动。使用此按键组合来重新安装随 Mac 预装的 macOS 版本或仍可用的最接近版本。


## Utilities

### pdf

```bash
brew install poppler
# 基础转换：将 input.pdf 每一页转换为 PNG 图片（命名为 output-01.png, output-02.png）
pdftoppm -png input.pdf output

```