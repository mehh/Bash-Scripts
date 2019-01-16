#!/bin/bash
#----------------------------------------------------------------------------------------------#
# WebScrape.sh v0.1 (#0 2016-05-18) 					                                       #
#                                                                                              #
############################## Modification Log ##############################
# Date          Who             Version         Description
# 20160518      kchase			0.1             Initial Release    
IFS="," 
while read v_line
do
	v_URL=`echo ${v_line} | cut -d"," -f1`

	tmSymbol='™'
	regSymbol='®'
	copySymbol='©'

	status=$(curl -A "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8)" -w "%{http_code}" -o temp -L --silent "$url")
	if [[ "$status" =~ "200" ]]
	then
		grep '®' temp 

		rm  temp
	fi

done < "$1"