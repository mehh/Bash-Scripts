#!/bin/sh
#	ssh_copy_id_push : push an alternate authorized key.
# and assemble a CSV list of results
# Note if there's no access, or password required, or no response.
#
# You can use this script to authenticate with a number of servers
# This script can take a set of passwords, try them via ssh and once successful, deploy an SSH key

IDPUBFILE="id_rsa.pub"
HOSTFILE="hostlist"
OUTFILE="/tmp/CM_host_status.csv"
KILLFILE="/tmp/kills.out"
cat /dev/null > "$KILLFILE"
SLEEP_DELAY=10

v_ssh_status_tmp="/tmp/ssh_status_tmp/"
mkdir -p "$v_ssh_status_tmp"

#Initialize spawn counters.
v_spawn=5
v_count=0
v_process_count=0

while [ x"$#" != x"0" ]
do
#  host file
	if [ x"$1" = x"-f" ];then
		shift
		HOSTFILE="$1"
		shift

#   mode
  	elif [ x"$1" = x"-g" ];then
   	 	shift
   		v_batchmode="$1"
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

		# delay
	elif [ x"$1" = x"-s" ];then
		shift
		v_spawn="$1"
		shift
# id file
	elif [ x"$1" = x"-i" ];then
		shift
		IDPUBFILE="$1"
		shift

# Usage
	elif [ x"$1" = x"-h" ];then
        echo "		Usage: ssh_status.sh [-f HOSTFILE ] [-d DELAY] [-o OUTFILE] [-c COMMAND]"
        echo "		-f HOSTFILE : list of hosts to run command on, default /tmp/hostfile"
		echo "		-d SLEEP-DELAY: the delay waiting for a command before it is killed as nonresponsive; "
		echo "		default is 5 seconds."
        echo "		-o OUTFILE : CSV list of nodes with output:"
        echo "		-i IDPUBFILE: Text file containing public key to push."
		echo "		<hostname>,NOPING: not responding to ping"
		echo "		<hostname>,NORESPONSE: command timed out and session was killed"
		echo "		<hostname>,OK: successful"
		echo " "
		exit 0
# No arguments
	fi

	if [ ! -f "$IDPUBFILE" ];then
	  echo "ID file $IDPUBFILE not found."
	fi
done		# end of arugment loop

# Initialize OUTFILE
touch ${OUTFILE}
cat /dev/null > ${OUTFILE}
cat /dev/null > ${OUTFILE}.full

if [ "$v_batchmode" != "true" ];then
	echo "Using:"
	echo "   Host list:  ${HOSTFILE}"
	echo "   Out File:   ${OUTFILE}"
	echo "   Delay:      ${SLEEP_DELAY}"
	echo "   Command:    ${v_COMMAND}"
	echo ""
	echo ""
fi

# for each nodename in the hostfile,
# test for DNS definition. If it's defined, ping it.
#	if the node answers a ping within 5 seconds, run the
#	ssh command
#	if not, advise and continue.

v_syscount=`cat ${HOSTFILE} | wc -l`

while read v_line
do
#  # count a number of processes, then wait a bit.
    if [ "${v_runalready}" != "1" ];then
      echo -ne "\n      Spawning another ${v_spawn} overlords...\n"
    fi

   if [ "$v_count" != "$v_spawn" ];then
      let v_count+=1
      let v_process_count+=1
      v_runalready=1
   else
      let v_count+=1
      sleep 1
        v_numleft=`echo "${v_syscount}-${v_process_count}"|bc -l`
        if [ ${v_numleft} -lt ${v_spawn} ]; then
         echo -ne "\n      Spawning another ${v_numleft} overlords...\n"
        else
         echo -ne "\n      Spawning another ${v_spawn} overlords...\n"
        fi
      v_runalready=1
      v_count=0
   fi

   # Start subshell to execute commands.
   (
      HOST=`echo "${v_line}"|awk -F',' '{print $1}' `

      v_PERCENT=`echo "scale=4;${v_process_count} / ${v_syscount}*100" | bc -l` > /dev/null
      v_PERCENT=$(echo "${v_PERCENT}" | awk ' sub("\\.*0+$","") ')

      v_HOSTlength=$(( 20 - $((${#HOST} )) ))

	    COUNTER=0
	    RANDOMVAR=""

	    while [ ${COUNTER} -lt ${v_HOSTlength} ];
	    do
	      RANDOMVAR="${RANDOMVAR} "
	      let COUNTER=COUNTER+1
	    done

	    echo -ne "    -- ${HOST}${RANDOMVAR}${v_process_count}/${v_syscount}(${v_PERCENT}%)        \n"


	    ping -c 1 -w 5 $HOST  > /dev/null 2>&1
	    PINGSTAT=$?
	    if [ x"$PINGSTAT" = x"0" ];then


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
		ssh-copy-id -i "${IDPUBFILE}" ${HOST} -o TCPKeepAlive=no -o ConnectTimeout=10 -o PasswordAuthentication=no -o ServerAliveInterval=5 -o StrictHostKeyChecking=no -o BatchMode=yes  > "$v_ssh_result_tmp" 2>&1
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
		if grep "Permission denied" "$v_ssh_result_tmp" > /dev/null 2>&1 ;then
	           v_permden="1"
		fi
			ps -p "$v_PID" >> /tmp/killdecide 2>&1
			v_psrc="$?"

	        if [ "$v_psrc" = "0" ];then
	#       #Kill process if still going.
	        	kill -9 ${v_PID} >> "$KILLFILE" 2>&1
				echo "${HOST},NORESPONSE" >> "${v_ssh_status_tmp}${HOST}.result"
				echo " "	# feed a newline.
			else
	#       #Determine if it went ok or if keys weren't set up.
	           if [ x"$v_rc" = x"0" ];then
	              echo "${HOST},OK" >> "${v_ssh_status_tmp}${HOST}.result"
	           elif [ x"$v_rc" = x"127" ];then
	              echo "${HOST},CONNECT_SUCCESS_BUT_REMOTE_COMMAND_DOESNT_EXIST" >> "${v_ssh_status_tmp}${HOST}.result"
	           elif [ x"$v_rc" = x"255" ];then
		      		if [ x"$v_permden" = x"1" ];then
	                	echo "${HOST},PERMISSION_DENIED" >> "${v_ssh_status_tmp}${HOST}.result"
		     		elif grep -i "refused" "$v_ssh_result_tmp" > /dev/null;then
	                	echo "${HOST},SSH_TIMEOUT" >> "${v_ssh_status_tmp}${HOST}.result"
					else
		     			echo "${HOST},UNKNOWN_ERROR" >> "${v_ssh_status_tmp}${HOST}.result"
		      		fi
	           else
	#          #Remote command failed.
	              echo "${HOST},CONNECT_SUCCESS_BUT_REMOTE_COMMAND_FAILED_WITH_$v_rc" >> "${v_ssh_status_tmp}${HOST}.result"
		   fi
	        fi
		cat "$v_ssh_result_tmp" >> "${v_ssh_status_tmp}${HOST}.full"
	#       #Delete temp files.
		rm -f "$v_ssh_rc_tmp"
		rm -f "$v_ssh_result_tmp"
		rm -f "$v_ssh_complete"

	# If there was no response from the ping.
	    else
			#echo -- "${HOST} not active"
		echo "${HOST},NOPING" >> "${v_ssh_status_tmp}${HOST}.result"
	    fi		# end PINGSTAT
	) &
done < "$HOSTFILE"

echo "      Waiting for children to finish..."
wait
echo "      all children finished..."

#compile the results
cat "${v_ssh_status_tmp}"*.result > "${OUTFILE}"
cat "${v_ssh_status_tmp}"*.full > "${OUTFILE}.full"

#Clean up the directories.
rm -rf "$v_ssh_status_tmp"

echo "      Number of processes forked: $v_process_count"

exit
