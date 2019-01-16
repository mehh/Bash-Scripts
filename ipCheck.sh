#!/bin/bash
#   Script by Kris Chase
#   https://krischase.com
#
#   Quick and dirty script to get the IP address of hostname


while read p; do


 v_IP=`dig +short $p`
if [[ x"${v_IP}" == x"" ]];then
	echo "${p},down"
else
	echo ${p},${v_IP}
fi



done < $1