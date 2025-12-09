function mm() {
   multidircmd 2 mvn $@
}

# 在多个目录中批量执行命令
# 参数1: 指定后续有多少个参数属于命令部分
# 后续参数: 拼接成要执行的完整命令
# 剩余参数: 目标目录列表
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
