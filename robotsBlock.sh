#!/bin/bash
#	Script by Kris Chase
#	http://krischase.com
#
#	robotsDeploy.sh is a script which will take a templated robots.txt file
#	and deploy it to all users accounts on the current system
#	Meant for systems running WHM

	#Initialize variables counters.
	v_cpanel_accounts=0

	#	Setup function for help
	help()
	{
	    echo "		Usage: robotsDeploy.sh [-f filename]"
	    echo "		-f robots.txt File : File with base robots.txt"
		echo " "
		exit 1
	}

	while getopts "f:h" OPTIONS; do
	   case ${OPTIONS} in
	      f ) v_robotsTemplate=$OPTARG ;;
	      h ) help ;;
	      * ) echo "Unknown option" 1>&2; help; exit 2 ;; # Default
	   esac
	done

	if [ ! -f ${v_robotsTemplate} ]; then
	    echo "File not found!"

	    exit 1;
	fi

	ls -1 /var/cpanel/users | while read user; do
		if [ x"$user" != x"root" ];then

			echo "Setting robots.txt for: ${user}"

			# Find sites documentroot
			v_DocumentRoot=`uapi --user=${user} SiteTemplates list_user_settings|grep -i documentroot|awk -F': ' '{print $2}'`

			mkdir -p ${v_DocumentRoot}
			touch ${v_DocumentRoot}/robots.txt
			cat ${v_robotsTemplate} > ${v_DocumentRoot}/robots.txt

			chown ${user}:${user} ${v_DocumentRoot}/robots.txt
			let v_cpanel_accounts+=1
		fi
	done


echo "	Number of robots.txt files updated: ${v_cpanel_accounts}"

exit