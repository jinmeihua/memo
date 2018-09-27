nohup ~/CTP/shell/init_path/run_shell.sh --enable-report --report-cron="0 50 9,14,17 * * ?" --issue="http://jira.cubrid.org/browse/22196" --mailto=" " --mailcc=" " --loop --update-build --next-build-url="cubridqa_781.conf" --prompt-continue=yes --extend-script=check.sh &

###################################

ps -u $USER f|grep -v cub_cas
pid_run_shell=`ps -u $USER |grep run_shell |awk {'print $1'}`
kill -9 `ps o pid,ppid,pgid,cmd |grep $pid_run_shell |awk {'print $1'}`
kill -9 `ps ajx|grep $UID|grep $pid_run_shell --color|awk {'print $2'}`
pkill cub
ps -u $USER f

###################################

grep INFO nohup.out | grep FAULT|grep -v echo 
grep -nE 'INFO|UPGRADE' nohup.out |grep -v echo|grep -vE 'TEST S|mail|CUBRIDException|Reporter'

###################################

sum=0; for x in `grep INFO nohup.out | grep FAULT|grep -v echo |awk '{print $NF}'`; do sum=$((sum + x)); done ; 
num=`grep INFO nohup.out | grep FAULT|grep -v echo -c` 
avg=$(echo "scale=1; $sum/$num"| bc )  
echo "sum= $sum , num= $num , avg= $avg"
echo "Avg number of FI: $avg (total $sum)"
ll ~/ERROR_BACKUP

###################################

grep -nE "^\[INFO\] 'FAULT INJECTION'|UPGRADE" nohup.out > info.log
length=`cat info.log |wc -l`
sum=0; num=0; cur_row=0;

cat info.log | while read line
do
   if [ `echo "$line" | grep -c 'UPGRADE'` -gt 0 ]
   then
     rownum=`echo $line  |cut -f 1 -d ":"`
     if [ $rownum -eq 1 ]
     then
        echo "$line"
     else
       avg=$(echo "scale=1; $sum/$num"| bc )
       echo "sum= $sum , num= $num , avg= $avg"
       echo "Avg number of FI: $avg (total $sum)"
       
       sum=0; 
       num=0;
       echo "$line"
     fi
   else
     n=`echo "$line"|awk '{print $NF}'`
     sum=$((sum + n)); 
     num=$((num + 1)); 
   fi
   
   cur_row=$((cur_row + 1))
   if [ $cur_row -eq $length ]
   then
      avg=$(echo "scale=1; $sum/$num"| bc )  
      echo "sum= $sum , num= $num , avg= $avg"
      echo "Avg number of FI: $avg (total $sum)"
   fi
done ; 
