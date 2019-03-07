function gogetp(){
    export GO111MODULE=off
    go get -v -u $1
}

function goget(){
    dtruss go get -v $1 2>&1 |  pv -i 0.05 > /dev/null
}

function goupdate(){
    dtruss go get -u -v $1 2>&1 |  pv -i 0.05 > /dev/null
}

