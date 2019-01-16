#!/bin/bash

find /home/ -name version.php | while read line; do
#    echo "Processing file '$line'"

	if grep --quiet wp ${line}; then
		v_Name=`echo ${line} | awk -F'/' '{ print $3 }'`
		v_Version=`grep '^\$wp_version' "${line}" | cut -d "'" -f 2`
		#v_Version=`wp --allow-root --path=${line} core version`

		echo "${v_Name},${v_Version}"
	fi

done