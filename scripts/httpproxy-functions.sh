function sethttpproxy(){
  export http_proxy=http://localhost:7777
  export https_proxy=http://localhost:7777
}

function cleanhttpproxy(){
  export http_proxy=
  export https_proxy=
}
