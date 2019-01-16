#!/bin/sh
#	ssh_status : run a ssh command  on a list of targets
# and assemble a CSV list of results 
# Note if there's no access, or password required, or no response.
#

v_COMMAND="uname -a"
HOSTFILE="hostlist"
OUTFILE="/tmp/CM_host_status.csv"
SLEEP_DELAY=10

while [ x"$#" != x"0" ]
do
# command
	if [ x"$1" = x"-c" ];then
		shift
		v_COMMAND="$1"
		shift

#  host file
	elif [ x"$1" = x"-f" ];then
		shift
		HOSTFILE="$1"
		shift

# delay
	elif [ x"$1" = x"-d" ];then
		shift
		SLEEP_DELAY="$1"
		shift

# output
	elif [ x"$1" = x"-o" ];then
		shift
		OUTFILE="$1"
		shift

# Usage
	elif [ x"$1" = x"-h" ];then
        echo "		Usage: ssh_status.ksh [-f HOSTFILE ] [-d DELAY] [-o OUTFILE]"
        echo "		-f HOSTFILE : list of hosts to run command on, default /tmp/hostfile"
		echo "		-d SLEEP-DELAY: the delay waiting for a command before it is killed as nonresponsive; "
		echo "		default is 5 seconds."
        echo "		-o OUTFILE : CSV list of nodes with output:"
		echo "		<hostname>,NOPING: not responding to ping"
		echo "		<hostname>,NORESPONSE: command timed out"
		echo "		<hostname>,OK: successful"
		echo " "
		exit 0
# No arguments
	fi
done		# end of arugment loop

# Initialize OUTFILE
touch ${OUTFILE}
cat /dev/null > ${OUTFILE}
cat /dev/null > ${OUTFILE}.full
echo "Using:"
echo "   Host list:  ${HOSTFILE}"
echo "   Out File:   ${OUTFILE}"
echo "   Delay:      ${SLEEP_DELAY}"
echo "   Command:    ${v_COMMAND}"
echo ""
echo ""


# for each nodename in the hostfile,
# test for DNS definition. If it's defined, ping it.
#	if the node answers a ping within 5 seconds, run the 
#	ssh command 
#	if not, advise and continue.

while read v_line
do

   HOST=`echo "${v_line}"|awk -F'|' '{print $1}' `

    ping -c 1 -w 5 $HOST  > /dev/null 2>&1
    PINGSTAT=$?
    if [ x"$PINGSTAT" = x"0" ];then
	echo "-- $HOST"

    v_ssh_rc_tmp=`mktemp`
    v_ssh_result_tmp=`mktemp`
    v_ssh_complete=`mktemp`

#       # Initialize temp files
	echo "" > "$v_ssh_rc_tmp"
	echo "" > "$v_ssh_result_tmp"
        echo "" > "$v_ssh_complete"


#       #Spawn subshell with the ssh command.
	( 
#       #SSH ARGS:
#       # -n used to prevent stdin from taking over the loop.
#       # PasswordAuth and BatchMode for preventing Password prompts.
#       # TCPKeepAlive and ServerAlive for timeouts (Helps)
	ssh root@${HOST} -n -o TCPKeepAlive=no -o ConnectTimeout=10 -o PasswordAuthentication=no -o ServerAliveInterval=5 -o StrictHostKeyChecking=no -o BatchMode=yes "$v_COMMAND" > "$v_ssh_result_tmp" 2>&1 
#       # get the return code if finished. Must be to a file.
	echo "$?" > "$v_ssh_rc_tmp"
	echo "1" > "$v_ssh_complete"
	) &  

#       #Get the PID for possible killing later.
	v_PID=$!
#       # Need a minimum of 1 second delay for ssh to finish.
        v_SLEEPCOUNTER=0
	while test "`cat $v_ssh_complete`" != "1" && test "${v_SLEEPCOUNTER}" != "${SLEEP_DELAY}"  
	do
		sleep 1
		let v_SLEEPCOUNTER+=1
	done

#       # Check if ssh finished. Delay otherwise.
	if [ x"`cat $v_ssh_complete`" = x"1" ];then
	   echo "0" > "$v_ssh_complete"
	else
	   sleep ${SLEEP_DELAY}
	   echo "0" > "$v_ssh_complete"
	fi
#       #Get the return code of the forked Process
	v_rc=`cat "$v_ssh_rc_tmp"`

#       #Check if permission denied.        
	v_permden=""
	if grep "Permission denied" "$v_ssh_result_tmp";then
           v_permden="1"
	fi

        if ps | grep "$v_PID";then
#       #Kill process if still going.
        	kill -9 ${v_PID}
			echo "${HOST},NORESPONSE" >> ${OUTFILE}
			echo " "	# feed a newline.
		else
#       #Determine if it went ok or if keys weren't set up.
           if [ x"$v_rc" = x"0" ];then
              echo "${HOST},OK" >> ${OUTFILE}
           elif [ x"$v_rc" = x"127" ];then
              echo "${HOST},CONNECT_SUCCESS_BUT_REMOTE_COMMAND_DOESNT_EXIST" >> ${OUTFILE}
           elif [ x"$v_rc" = x"255" ];then
	      		if [ x"$v_permden" = x"1" ];then
                	echo "${HOST},PERMISSION_DENIED" >> ${OUTFILE}	     		
	     		elif grep -i "refused" "$v_ssh_result_tmp" > /dev/null;then
                	echo "${HOST},SSH_TIMEOUT" >> ${OUTFILE}
				else
	     			echo "${HOST},UNKNOWN_ERROR" >> ${OUTFILE}                	
	      		fi
           else
#          #Remote command failed. 
              echo "${HOST},CONNECT_SUCCESS_BUT_REMOTE_COMMAND_FAILED_WITH_$v_rc" >> ${OUTFILE}
	   fi
        fi
	cat "$v_ssh_result_tmp" >> ${OUTFILE}.full
#       #Delete temp files.
	rm -f "$v_ssh_rc_tmp"
	rm -f "$v_ssh_result_tmp"
	rm -f "$v_ssh_complete"

# If there was no response from the ping.
    else
	echo -- "${HOST} not active"
	echo "${HOST},NOPING" >> ${OUTFILE}
    fi		# end PINGSTAT
done < "$HOSTFILE"
exit