
function encode64(){
  s=$(echo -n $1 | openssl base64 | tr -d '\n')
  echo $s
  echo $s | pbcopy
}

function decode64(){
  s=$(echo "$1" | openssl base64 -d)
  echo $s
  echo $s | pbcopy
}
