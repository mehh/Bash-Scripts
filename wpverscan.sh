#!/bin/bash

find / -name wp-config.php | sed s/'wp-config.php'//g| while read line; do
#    echo "Processing file '$line'"

	v_Name=`echo ${line} | awk -F'/' '{ print $3 }'`
	v_Version=`wp --allow-root --path=${line} core version`

	echo "${v_Name},${v_Version}"
done

