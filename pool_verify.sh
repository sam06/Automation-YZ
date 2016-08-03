#!/bin/bash

#NFS_DIR=/nfs/shared/SaaSOperations/OneTime-Config-Setup
#base_dir=${NFS_DIR}/Automation-Utils
#conf_dir=${NFS_DIR}/Automation-Config
#
#pool_id=$1
#dc=$2
#zone=$3
#if [ $# -ne 3 ];then
#   echo "Usage: $0 <POOL_ID|Ex:sc8lp13> <DC|Ex:DC8> <ZONE|Ex:RZ,YZ>"
#exit 0
#fi
#
#
#
#if [ "$pool_id" == "All" ] || [ "$pool_id" == "all" ]; then
##servers=`cat $conf_dir/$dc-$zone/pool.properties | grep "^pool.\[${pool_id}\].app.nodes" | cut -f 2 -d "="`
#servers=`cat $conf_dir/$dc-$zone/pool.properties | grep -v "#" | grep ".app.nodes" | cut -f 2 -d "=" | sed '/^$/d' |tr '\n' ',' | sed 's/,$//g'`
##echo Servers available in $dc $zone are = $servers
#else
#servers=`cat $conf_dir/$dc-$zone/pool.properties | grep "^pool.\[${pool_id}\].app.nodes" | cut -f 2 -d "="`
##echo Servers available in $pool_id are = $servers
#fi
#
#IFS=',' read -a sarray <<< "$servers"
#
##echo "------------------------------"
##printf "\n|%9s|%9s|%9s|%9s|%10s|%10s|%10s|%10s|%10s|\n" "Node" "Heap_Std" "Pem_Std" "Jdk" "TMS_Running" "LMS_Version" "BgJob" "Puppet_Running" "jdk_rpm"
echo  "Node,Heap_S,Pem_S,Jdk,Jdk_rpm,TMS_Run,LMS_Ver,BgJob,CPU_info,Mem_info,T_Zone,C_Max,C_Min,M_Loop_S,P_H_Wt,P_L_Wt,P_Rep_Cap,P_Conn_Cap,Log_R,Puppet_R"
##echo "----------------------------------------------------------"
#        for node in "${sarray[@]}"
#        do
#          ssh -q -T -o "StrictHostKeyChecking no" -o "ConnectTimeout 20" $node < \EOF
          hostname=`hostname -f`
          jdk=`facter sf_jdk_home |cut -f 4 -d "/"`
          version=`facter sf_lms_ver | awk '{print $NF}'`
          jdkrpm=`rpm -qa |grep jdk* | awk '{print $NF}'`
          bgjob=`ps -ef |grep java |grep "DenableBackgroundJobExecution=true" |wc -l | awk '{print $NF}'`
if [ "$bgjob" == "1" ];then
                  bgjob="True"
          else
                  bgjob="False"
fi
         puppet=`sudo /etc/init.d/puppet status`
if [ "$?" == "0" ];then
                  puppet="True"
          else
                  puppet="False"
fi

if [ "`cat /local/customers/plateau/start-tms.sh |grep \"Xms20480m\" |wc -l`" == "1" ];then
                  heap="20480m"
          elif [ "`cat /local/customers/plateau/start-tms.sh |grep \"Xms10240m\" |wc -l`" == "1" ];then
                  heap="10240m"
          else
                  heap="Non-Standard"
fi

if [ "`cat /local/customers/plateau/start-tms.sh |grep MaxPermSize=4096m |wc -l`" == "1" ];then
                  pem="4096m"
          elif [ "`cat /local/customers/plateau/start-tms.sh |grep MaxPermSize=2048m |wc -l`" == "1" ];then
                  pem="2048m"
          else
                  pem="Non-Standard"
fi
tms=`ps -ef |grep java|grep -v grep |wc -l | awk '{print $NF}'`
if [ "$tms" == "1" ];then
                tms="True"
          else
                tms="False"
         fi
cpu=`cat /proc/cpuinfo |grep "processor" |wc -l`
mem=`free -m |grep "Mem" |awk '{print $2}'`
timezone=`facter timezone`
pminc=`cat /local/customers/plateau/.tms/PlateauDS.properties |grep "connectionPoolMinSize" |cut -f 2 -d "="`
pmaxc=`cat /local/customers/plateau/.tms/PlateauDS.properties |grep "connectionPoolMaxSize" |cut -f 2 -d "="`
mainloop=`cat /local/customers/plateau/.tms/JobExecutionService.properties |grep "mainLoopSchedule" |cut -f 2 -d "=" |cut -f 2 -d "/" |cut -f 1 -d " "`
p_heavy_cap=`cat /local/customers/plateau/.tms/JobExecutionService.properties |grep "pool.HeavyWeight.capacity" |cut -f 2 -d "="`
p_light_cap=`cat /local/customers/plateau/.tms/JobExecutionService.properties |grep "pool.LightWeight.capacity" |cut -f 2 -d "="`
p_report_cap=`cat /local/customers/plateau/.tms/JobExecutionService.properties |grep "pool.Report.capacity" |cut -f 2 -d "="`
p_conn_cap=`cat /local/customers/plateau/.tms/JobExecutionService.properties |grep "pool.Connector.capacity" |cut -f 2 -d "="`
log_r=`sudo crontab -l |grep logrotate | grep -v "#" |wc -l`
if [ "$log_r" == "1" ];then
                     log_r="True"
         else
                     log_r="False"
fi
#printf "\n|%6s|%6s|%8s|%10s|%10s|%10s|%6s|%6s|%10s|\n" "$node" "$heap" "$pem" "$jdk" "$tms" "$version" "$bgjob" "$puppet" "$jdkrpm" >
echo   "$hostname,$heap,$pem,$jdk,$jdkrpm,$tms,$version,$bgjob,$cpu,$mem,$timezone,$pmaxc,$pminc,$mainloop,$p_heavy_cap,$p_light_cap,$p_report_cap,$p_conn_cap,$log_r,$puppet"
EOF
        done
echo " "
#echo "-----------------"