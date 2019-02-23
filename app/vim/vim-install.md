
# Steps

## vimrc
 add `~/.vimrc`
##  nvim

- `brew install neovim`
- add `~/.config/nvim/init.vim` following [FAQ](https://github.com/neovim/neovim/wiki/FAQ)

## plugins
```
cd ~/.vim/pack/plugins/start 

git clone --depth=20 https://github.com/fatih/vim-go.git 
git clone --depth=20 https://github.com/fatih/molokai.git 
git clone --depth=20 https://github.com/AndrewRadev/splitjoin.vim.git
git clone --depth=20 https://github.com/ctrlpvim/ctrlp.vim 
git clone --depth=20 https://github.com/mdempsky/gocode 
git clone --depth=20 https://github.com/sebdah/vim-delve 
git clone --depth=20 https://github.com/scrooloose/nerdtree.git 
git clone --depth=20 https://github.com/MarcWeber/vim-addon-mw-utils.git
git clone --depth=20 https://github.com/honza/vim-snippets.git
git clone --depth=10 https://github.com/posva/vim-vue.git
```

using `:GoInstallBinaries` to install golang plugins 

### vim-jsbeautify
```
cd ~/.vim/pack/plugins/start 

# download plugin vim-jsbeautify/plugin/beautifier.vim
git clone --depth=10 https://github.com/maksimr/vim-jsbeautify.git

# download js-beautify
wget https://github.com/beautify-web/js-beautify/archive/v1.8.9.zip
unzip v1.8.9.zip 

mkidr -p vim-jsbeautify/plugin/lib/js/lib
cp js-beautify-1.8.9/js/lib/*.js  vim-jsbeautify/plugin/lib/js/lib

# edit .editorconfig
# change all indent-size to 2
```

## alias

add following into .zshrc:
```
alias vi="nvim"
alias vim="nvim"
```

## [optional] oh-my-zsh theme

```
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
```

## [optional] dracula theme

```
mkdir -p ~/vim/theme
git clone --depth=20 https://github.com/dracula/iterm.git ~/.vim/theme/iterm

# iTerm2 > Preferences > Profiles > Colors Tab
# Open the Color Presets... drop-down in the bottom right corner
# Select Import... from the list
# Select the Dracula.itermcolors file
# Select the Dracula from Color Presets..
```
