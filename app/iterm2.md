<!---
markmeta_author: wongoo
markmeta_date: 2019-07-17
markmeta_title: iterm2
markmeta_categories: app
markmeta_tags: iterm2
-->

# iterm2 

## install
```
brew install zsh

sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

```

## change theme
edit `~/.zshrc`:

```
ZSH_THEME="agnoster"
```

change theme config:
```bash

cd .oh-my-zsh/themes
vi agnoster.zsh-theme

## Main prompt
build_prompt() {
  RETVAL=$?
  prompt_status 
  prompt_virtualenv
  prompt_aws
  # prompt_context   ----> 注释掉这一行
  prompt_dir
  prompt_git
  prompt_bzr
  prompt_hg
  prompt_end
}
```
