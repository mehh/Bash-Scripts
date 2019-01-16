#! /bin/bash
#----------------------------------------------------------------------------------------------#
#   Script by Kris Chase
#   https://krischase.com
#   pw-cpanel.sh v0.1 (#0 2016-01-05)
#
# This script will handle changing passwords for all cPanel users
############################## Modification Log ##############################
# Date          Who             Version         Description
# 20160105      KChase			0.1             Initial Release
#----------------------------------------------------------------------------------------------#


	v_MyIP=`dig +short myip.opendns.com @resolver1.opendns.com`

	export ALLOW_PASSWORD_CHANGE=1

	ls -1 /var/cpanel/users | while read user; do
		pass=$(</dev/urandom tr -dc '12345!@#$%qwertQWERTasdfgASDFGzxcvbZXCVB' | head -c16; echo "")

		/scripts/realchpass ${v_Username} ${v_Password}
		/scripts/mysqlpasswd ${v_Username} ${v_Password}

		echo "https://${v_MyIP}:2083 ${v_MyIP} ${v_Username} ${v_Password}"
	done