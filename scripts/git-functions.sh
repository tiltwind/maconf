function gitc(){
  git clone --depth=1 $1
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

function gmerge() {
    git checkout $1
    git pull -v
    git push origin $1:$2
    if [ $? -eq 0 ]; then
    	echo "merged"
    else
    	git checkout $2
    	git pull -v
    	git merge $1 --commit --no-edit
    	git push -v
    	git checkout $1
    fi
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

function gitpushdirs(){
  for p in `find . -type d -depth 1 `
  do
    cd $p

    if [ -d .git ]
    then
      git add .
      git commit -a -m "$1"
      git push -v
    fi

    cd ..

  done
}


function gitdelbranch(){
    git push -d origin $1
    git branch -d $1
}