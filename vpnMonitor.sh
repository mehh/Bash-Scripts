#!/bin/bash
# Run script as # nohup ./vpn-monitor.sh /dev/null 2>&1 &

vpn_clientA(){

vpnName="upi"
endpoint="10.80.12.44" # endpoint1 inside tunnel
endpoint2="10.80.12.44" # endpoint2 inside tunnel

count=$( ping -c 3 $endpoint | grep icmp* | wc -l )
count2=$( ping -c 3 $endpoint2 | grep icmp* | wc -l )

if [ $count -eq 0 -a $count2 -eq 0 ] # Echo reply not received.
    then
    # Ping failed
    echo "Ping FAILED $(date)" >> /var/log/vpnc/$vpnName.log

    # Sending email notification
    echo "Ping for $endpoint FAILED! More info /var/log/vpnc/$vpnName.log " | mail -s "VPN $vpnName failed " kris@krischase.com

    # restart connection
    # pkill vpnc
    /usr/sbin/vpnc /etc/vpnc/upi >> /var/log/vpnc/$vpnName.log &

else
    echo "Ping replied $(date)" >> /var/log/vpnc/$vpnName.log
fi
}


while : # infinite cycle
do
# call function every 30 seconds
vpn_clientA
sleep 30