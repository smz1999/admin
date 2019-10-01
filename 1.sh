#!/bin/bash
disk_info=/root/disk_list.txt
ip=`ip add | grep "dynamic" |awk '{print $2}' | sed 's/\/24//'`
day=`date +%Y-%m-%d`
host=`hostname`
file=/root/disk_mail.txt

df -h | grep -v "文件系统" | grep "^/dev" > ${disk_info}

while read line
do
	disk_name=`echo $line | awk '{print $1,$NF"分区"}'`
	disk_Total=`echo $line | awk '{print $2}'`
	disk_free=`echo $line | awk '{print $4}'`
	disk_Percent=`echo $line | awk '{print $5}' | sed 's/%//g'`
	if [ $disk_Percent -ge 85 ]
	then
cat > $file <<eof
===============================
service: Disk Check 
host: $host
ip: $ip
date: $day
===============================
Disk: $disk_name has Used ${disk_Percent}% and free: $disk_free
eof
		echo "$disk_name has Used ${disk_Percent}% and free: $disk_free ,plesae check...." 
		mail -s "$disk_name Warning" root@127.0.0.1 < $file
	fi
done < ${disk_info}

rm -rf $file
rm -rf ${disk_info}
