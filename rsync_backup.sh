#!/bin/bash
#1.定义变量
Host=$(hostname)
Ip=$(ifconfig  | grep -i "255.255.255.0" | awk '{print $2}')
Day=$(date +%F)
BackupDir=/backup
Dest=${BackupDir}/${Host}_${Ip}_${Day}

#2.创建备份目录
mkdir -p $Dest

#3.收集备份文件
#sysconf backup
tar -cf ${Dest}/sysconf.tar /etc/fstab /etc/hosts /var/spool/cron/root
#logs backup
tar -cf ${Dest}/logs.tar /var/log/messages /var/log/secure /var/log/cron
#conf backup
tar -cf ${Dest}/conf.tar /etc/rsyncd.conf

#4.文件校验
File=${Dest}/check_rsync_${Day}
md5sum $Dest/* > $File

#5.推送到rsync服务器上
Rsync_ip=192.168.31.120
Rsync_user=rsync_backup
Rsync_module=backup
export RSYNC_PASSWORD=123456
rsync -avz $Dest ${Rsync_user}@${Rsync_ip}::${Rsync_module}

#6.删除七天前的目录
find $BackupDir -type d -mtime +7 | xargs rm -rf 
