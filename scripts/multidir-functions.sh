function mm() {
   multidircmd 2 mvn $@
}

function multidircmd() {
    dcur=$(pwd)
    mcmd=""
    
    cmd_para_count=$(($1+1))
    count=0
    for onecmd in $@
    do
      ((count++))
      if [ $count -eq 1 ]; then
         continue
      fi

      if [ $count -gt $cmd_para_count ]; then
         break
      fi
      mcmd=$mcmd$onecmd" "
    done    

    echo "======> CMD: $mcmd"

    count=0
    for cdir in $@
    do
      ((count++))
      if [ $count -le $cmd_para_count ]; then
         continue
      fi
      if ! [ -d "$cdir" ]; then
          echo " ERROR DIR: $cdir"
          break
      fi
      echo "============> $cdir:$mcmd"
      cd $cdir
      eval $mcmd

      cd $dcur
    done
    cd $dcur
}
