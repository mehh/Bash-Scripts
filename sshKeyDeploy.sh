#!/bin/bash
#	Script by Kris Chase
#	https://krischase.com
#
#	SSh key deployment script.
#
#	Login to the server as root, this script will loop through all cPanel users
#	Script will add public keys from file provided to each cPanel user


#Initialize variables counters.
COUNTER=1

#	Setup function for help
help()
{
    echo "		Usage: sshKeyDeploy.sh [-f File with keys ]"
    echo "		-f Key File : File with public keys"
	  echo " "
	  exit 1
}

while getopts "f:h" OPTIONS; do
   case ${OPTIONS} in
      f ) v_keyfile=$OPTARG ;;
      h ) help ;;
      * ) echo "Unknown option" 1>&2; help; exit 2 ;; # Default
   esac
done

    if [ -n "${v_keyfile}" ]
    then

    	ls -1 /var/cpanel/users | while read user; do
    		if [ x"$user" != x"root" ];then
    			echo ${user}

    			mkdir -p /home/${user}/.ssh/
    			touch /home/${user}/.ssh/authorized_keys
    			cat ${v_keyfile} > /home/${user}/.ssh/authorized_keys
    			COUNTER=$[$COUNTER +1]
    		fi
    	done
    else
        echo "Please specify a file [-f] and try again!"
        exit
    fi





echo "	Number of keys deployed: ${COUNTER}"

exit
