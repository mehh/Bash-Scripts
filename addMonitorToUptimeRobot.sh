#! /bin/bash
#----------------------------------------------------------------------------------------------#
# addMonitorToUptimeRobot.sh v1.0 (#0 2016-05-05)                                              #
#                                                                                              #
# This script will loop through all users on WHM server,                                       #
# retreive associated domains and add them to Uptime Robot                                     #
############################## Modification Log ##############################                 #
# Date          Who             Version         Description                                    #
# 20160505      KChase			1.0             Initial Release                                #

## Get All Alerts
uptimerobot get-alerts|awk -F'#' '{print$2}'|while read v_alert; do
	v_alerts="${v_alert} "
done


cat /var/cpanel/users/*|grep 'DNS='|awk -F'=' '{print$2}'|grep -v whiteink|grep -v '*'|sort -u | while read v_domain; do

	uptimerobot new-monitor ${v_domain} http://${v_domain} --alerts ${v_alerts}
	echo "Added: ${v_domain}"
done