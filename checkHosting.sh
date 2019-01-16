#!/bin/bash
#   Script by Kris Chase
#   https://krischase.com
#
#   This script will take in a file that consists of a hostname, and the IP address that should resolve.
#   It will return whether or not the IP addresses match what is expected

while getopts "f:h" OPTIONS; do
   case ${OPTIONS} in
      f ) v_File=$OPTARG ;;
      h ) help ;;
      * ) echo "Unknown option" 1>&2; help; exit 2 ;; # Default
   esac
done

while read LINE; do
    # Grab our values from the file (comma seperated)
    v_hostname=`echo ${LINE}| cut -d, -f1`
    v_setIP=`echo ${LINE}| cut -d, -f2`

    # Get IP address of where domain is set to resolve in DNS
    v_actualIP=`dig +short $v_hostname`
    if [[ x"${v_actualIP}" == x"${v_setIP}" ]];then
    	v_HOSTING='YES'
    else
        v_HOSTING='NO'
    fi

    echo ${v_hostname},${v_HOSTING},${v_setIP},${v_actualIP}

done < ${v_File}

