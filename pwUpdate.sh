#!/bin/bash
#   Script by Kris Chase
#   http://krischase.com
#
#   Old version of a script which was used to update passwords for all WordPress users


while IFS= read -r site
do
    dbHost=`echo "${site}"	|	cut -d"	" -f1`
    dbName=`echo "${site}"	|	cut -d"	" -f2`
    dbUser=`echo "${site}"	|	cut -d"	" -f3`
    dbPwd=`echo "${site}"	|	cut -d"	" -f4`
    wpUser=`echo "${site}"	|	cut -d"	" -f5`
    wpPwd=`echo "${site}"	|	cut -d"	" -f6`


	echo -e "Updating ${dbHost} ....\n DB Name: ${dbName} \n DB User: ${dbUser} \n DB Pass: ${dbPwd} \n CMS User: ${wpUser} \n CMS Pass: ${wpPwd} \n ++++++++++++"

	mysql -h ${dbHost} -D ${dbName} -u ${dbUser} -p${dbPwd} -e "UPDATE wp_users SET user_pass = MD5('${wpPwd}') WHERE user_login='${wpUser}'"

done < "list.txt"