#! /bin/bash


while read line           
do           
	
	v_Account=`echo ${line} | awk -F',' '{print $1}'`
	v_Pass=`echo ${line} | awk -F',' '{ print $2}'`

	/scripts/mysqlpasswd ${v_Account} ${v_Pass}

	echo ${v_Account},${v_Pass}
done <	accounts.txt 