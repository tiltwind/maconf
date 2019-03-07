function gits(){
  git clone --depth=1 $1
}

function gitpulldirs(){
  for p in `find . -type d -depth 1 `
  do
    cd $p

    if [ -d .git ]
    then
      git pull -v
    fi

    cd ..

  done
}

function gdelbranch(){
    git push -d origin $1
    git branch -d $1
}

function gpush() {
    git add .
    git status
    echo "----------------"
    git commit -a -m "$1"
    echo "----------------"
    git push -v
}

function gmpush() {
    multidircmd 2 gpush $@
}
