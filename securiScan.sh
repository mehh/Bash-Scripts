#!/bin/bash
EMAIL="kris@krischase.com"

#add your websites here
sites[0]="www.celebrityspeakersbureau.com"
sites[1]="sports-speakers-bureau.com"
sites[2]="celebritychefnetwork.com"
sites[3]="pmgsports.com"
sites[4]="celebexperts.com"
#...
SENDEMAIL=0
for s in "${sites[@]}"
do
	WARNING=0
	> /tmp/malwarecheck.txt
	curl https://sitecheck.sucuri.net/results/$s | sed -n "/Security report/,/Spam/p" >> /tmp/malwarecheck.txt
	while read line; do
		if [[ "$line" == *error* ]]
		then
			WARNING=1
		fi
	done < /tmp/malwarecheck.txt
	if [ $WARNING -eq 1 ]
	then
        	SENDEMAIL=1
		echo "https://sitecheck.sucuri.net/results/$s:" >> /tmp/malwarecheckemail.txt
		cat /tmp/malwarecheck.txt >> /tmp/malwarecheckemail.txt
		echo "" >> /tmp/malwarecheckemail.txt
		echo "" >> /tmp/malwarecheckemail.txt
	fi
done
if [ $SENDEMAIL -eq 1 ]
then
	mail -s "URGENT: Malware detected!" $EMAIL < /tmp/malwarecheckemail.txt
fi
rm /tmp/malwarecheck.txt  2> /dev/null
rm /tmp/malwarecheckemail.txt 2> /dev/null