#!/bin/bash
#----------------------------------------------------------------------------------------------#
# The_Grand_Shutdown_script.sh v0.1 (#0 2012-07-09) BETA                                       #
#                                                                                              #
############################## Modification Log ##############################
# Date          Who             Version         Description
# 20120709      kchase/nwpickre 0.1             Initial Release
# 20120715      kchase          0.5            Many Bug Fixes, now fully supports "test" mode
# 20120716      kchase/nwpickre 0.8            Made the script run at least 5 times faster.



#----Start Variables----------------------------------------------------------------------------------------#
  #---Default Settings---------------------------------------------------------------------------------#
  # [ /test/poweroff] What do you want to do today?
  g_mode="test"

  # Startup directory
  g_PWD="$(pwd)"
  g_DT="$(date +%Y%m%d_%H%M%S)"

  # [/path/to/file] Location of the power off List(comma seperated values:
    #HOSTNAME,WINDOWS/LINUX/SOLARIS/HPUX/ESX/ESXI,PHYSICAL/VIRTUAL
  g_poweroffList="poweroffList.csv"

  #-Start Master List Variables------------------------------------------------------------------------#
    # Master lists after seperation.
    g_windowsHosts="${g_PWD}/lists/windows.csv"
    g_esxHosts="${g_PWD}/lists/esx.csv"
    g_esxiHosts="${g_PWD}/lists/esxi.csv"    
    g_aixHosts="${g_PWD}/lists/aix.csv"
    g_linuxHosts="${g_PWD}/lists/linux.csv"
    g_sunHosts="${g_PWD}/lists/sun.csv"
    g_hpuxHosts="${g_PWD}/lists/hpux.csv"
  #-End Master List Variables--------------------------------------------------------------------------#

  #-Start LogFiles Variables---------------------------------------------------------------------------#
    # [/path/to/file] Location of the folder/file(s). # Can't use ~/ with ""
    g_windowsLogs="${g_PWD}/logs/${g_DT}-windowsLog.csv"
    g_esxLogs="${g_PWD}/logs/${g_DT}-esxLogs.csv"
    g_esxiLogs="${g_PWD}/logs/${g_DT}-esxiLogs.csv"
    g_nixLogs="${g_PWD}/logs/${g_DT}-nixLogs.csv"
    g_aixLogs="${g_PWD}/logs/${g_DT}-aixLogs.csv"
    g_sunLogs="${g_PWD}/logs/${g_DT}-sunLogs.csv"
    g_hpuxLogs="${g_PWD}/logs/${g_DT}-hpuxLogs.csv"
  #-End LogFiles Variables-----------------------------------------------------------------------------#

  #-Start Script Locations-----------------------------------------------------------------------------#
    # [Seconds] How long to wait. Longer = higher chance of success.
    g_windowsScript="../windows_shutdown/windows_exec.sh"
    g_sshScript="../ssh_status/ssh_status.sh"
  #-End Script Locations-------------------------------------------------------------------------------#

  #-Start Timeout Variables----------------------------------------------------------------------------#
    # [Seconds] How long to wait. Longer = higher chance of success.
    g_sshTimeout="60"
    g_overlordSpawns_win="30"
    g_overlordSpawns_nix="25"
    g_overlordSpawns_esx="50"
    g_sleepDelay="15"
    g_sleepDelay_esx="900"
  #-End Timeout Variables------------------------------------------------------------------------------#

  #-Start Access Credentials---------------------------------------------------------------------------#
#    g_nixUsername="sdsadmin"
#    g_nixPassword="2wsx@WSX"
#    g_winUsername="sdsadmin"
#    g_winPassword="2wsx@WSX"
    g_nixUsername="sdsadmin"
    g_nixPassword="Drysp3ll"
    g_winUsername="sdsadmin"
    g_winPassword="Drysp3ll"
  #-End Access Credentials-----------------------------------------------------------------------------#

  #---Start Other Variables----------------------------------------------------------------------------#
    g_ping="false"                  # [true/false] Ping systems at end to verify down?
    g_debug=""                      # [""/"-d"] Output Diagnostic Debug Inforation
    g_verbose="true"                # [0/1/2] Shows more info. 0=normal, 1=more, 2=more+commands
    g_benchmark="true"              # [true/false] Attempt to generate an ETA by testing the system performance.
    g_logFile="${g_PWD}/tgss.log"   # [/path/to/file] Filename of output
    g_version="0.8"                 # Script version 
  #---End Other Variables------------------------------------------------------------------------------#
  
  #---Start Shutdown Commands--------------------------------------------------------------------------#
    g_ESX_shutdownCMD="rm -f vmExec.sh;wget -q -O vmExec.sh http://cm-catdev.usca.ibm.com/utils/misc/vmExec.sh > /dev/null 2>&1 || curl --silent -o vmExec.sh http://cm-catdev.usca.ibm.com/utils/misc/vmExec.sh > /dev/null 2>&1 || { echo 'ftp -u -n -i <<ENDOFINPUT' > ftpScript.sh; echo 'open cm-catdev' >> ftpScript.sh; echo 'user anonymous' >> ftpScript.sh; echo 'bi' >> ftpScript.sh; echo 'get vmExec.sh' >> ftpScript.sh; echo 'close' >> ftpScript.sh; echo 'bye' >> ftpScript.sh; echo 'ENDOFINPUT' >> ftpScript.sh; sh ftpScript.sh >/dev/null;rm -f ftpScript.sh; }; sh vmExec.sh onSuspend;sleep 5;poweroff"
    g_ESXi_shutdownCMD="rm -f vmExec.sh;wget -q -O vmExec.sh http://cm-catdev.usca.ibm.com/utils/misc/vmExec.sh > /dev/null 2>&1 || curl --silent -o vmExec.sh http://cm-catdev.usca.ibm.com/utils/misc/vmExec.sh > /dev/null 2>&1 || { echo 'ftp -u -n -i <<ENDOFINPUT' > ftpScript.sh; echo 'open cm-catdev' >> ftpScript.sh; echo 'user anonymous' >> ftpScript.sh; echo 'bi' >> ftpScript.sh; echo 'get vmExec.sh' >> ftpScript.sh; echo 'close' >> ftpScript.sh; echo 'bye' >> ftpScript.sh; echo 'ENDOFINPUT' >> ftpScript.sh; sh ftpScript.sh >/dev/null;rm -f ftpScript.sh; }; sh vmExec.sh onSuspend;sleep 5;poweroff"
    g_AIX_shutdownCMD="shutdown -F 0"
    g_HPUX_shutdownCMD="shutdown -hy 0"
    g_LINUX_shutdownCMD="poweroff"
    g_SOLARIS_shutdownCMD="/etc/shutdown -y -g0 -i5"
    g_SUNOS_shutdownCMD="/etc/shutdown -y -g0 -i5"
  #---End Shutdown Commands----------------------------------------------------------------------------#

  #---Start Test Commands------------------------------------------------------------------------------#
    #g_ESX_testCMD="rm -f vmExec.sh; curl --silent -o vmExec.sh http://cm-catdev.usca.ibm.com/utils/misc/vmExec.sh; sh vmExec.sh listAll"
    g_ESX_testCMD="rm -f vmExec.sh;wget -q -O vmExec.sh http://cm-catdev.usca.ibm.com/utils/misc/vmExec.sh > /dev/null 2>&1 || curl --silent -o vmExec.sh http://cm-catdev.usca.ibm.com/utils/misc/vmExec.sh > /dev/null 2>&1 || { echo 'ftp -u -n -i <<ENDOFINPUT' > ftpScript.sh; echo 'open cm-catdev' >> ftpScript.sh; echo 'user anonymous' >> ftpScript.sh; echo 'bi' >> ftpScript.sh; echo 'get vmExec.sh' >> ftpScript.sh; echo 'close' >> ftpScript.sh; echo 'bye' >> ftpScript.sh; echo 'ENDOFINPUT' >> ftpScript.sh; sh ftpScript.sh >/dev/null;rm -f ftpScript.sh; }; sh vmExec.sh listAll;"
    g_ESXi_testCMD="rm -f vmExec.sh;wget -q -O vmExec.sh http://cm-catdev.usca.ibm.com/utils/misc/vmExec.sh > /dev/null 2>&1 || curl --silent -o vmExec.sh http://cm-catdev.usca.ibm.com/utils/misc/vmExec.sh > /dev/null 2>&1 || { echo 'ftp -u -n -i <<ENDOFINPUT' > ftpScript.sh; echo 'open cm-catdev' >> ftpScript.sh; echo 'user anonymous' >> ftpScript.sh; echo 'bi' >> ftpScript.sh; echo 'get vmExec.sh' >> ftpScript.sh; echo 'close' >> ftpScript.sh; echo 'bye' >> ftpScript.sh; echo 'ENDOFINPUT' >> ftpScript.sh; sh ftpScript.sh >/dev/null;rm -f ftpScript.sh; }; sh vmExec.sh listAll;"
    #g_ESXi_testCMD="rm -f vmExec.sh;; sh vmExec.sh listAll"
    g_AIX_testCMD="uname -a"
    g_HPUX_testCMD="uname -a"
    g_LINUX_testCMD="uname -a"
    g_SOLARIS_testCMD="uname -a"
    g_SUNOS_testCMD="uname -a"
  #---End Test Commands--------------------------------------------------------------------------------#  

#----END Variables------------------------------------------------------------------------------------------#

#----Start Initialize --------------------------------------------------------------------------------------#
  # Make Logs Directory
    mkdir -p "${g_PWD}/logs/"

  # Clear out pre-generated list files
    rm -rf "${g_PWD}/lists/"

  # Make Host list Directory
    mkdir -p "${g_PWD}/lists/"

  # Clear screen
    clear

#----End Initialize ----------------------------------------------------------------------------------------#

#----START Functions---------------------------------------------------------------------------------#

  function help()
  { #help
     #----------------------------------------------------------------------------------------------#
     echo "

      Usage: sh the_grand_shutdown_script.sh

      Options:
       -i  [Comma seperated list]          ---  List of files containing server names to use. e.g. $g_poweroffList 

       -m  [test/shutdown]                 ---  Mode. e.g. $g_mode

       -p  [true/false]                    ---  Ping systems at end to verify down? e.g. $g_ping
       -v  [0/1/2]                         ---  Shows more info. 0=normal, 1=more, 2=more+commands e.g. $v_verbose
       -b  [true/false]                    ---  Attempt to generate an ETA by testing the system performance. e.g. $g_benchmark
       -x  []                              ---  Utilize Debug Mode (very verbose output)       
       -t  [seconds]                       ---  SSH Timeout wait (in seconds) e.g. $v_sshTimeout
       -d  [seconds]                       ---  Sleep Delay wait (in seconds) e.g. $g_sleepDelay
       -D  [seconds]                       ---  Sleep Delay wait (in seconds) e.g. $g_sleepDelay_esx   
       -s  [number]                        ---  Number of processes to fork for Windows(Use with caution!)  e.g. $g_overlordSpawns_win
       -S  [number]                        ---  Number of processes to fork for NIX (Use with caution!)  e.g. $g_overlordSpawns_nix   
       -E  [number]                        ---  Number of processes to fork for ESX (Use with caution!)  e.g. $g_overlordSpawns_esx       
       -l  [Logfile]                       ---  Used to specify logfile name and location e.g. $g_logFile

       -?                                 ---  This screen

      Example:
       sh the_grand_shutdown_script.sh
       sh the_grand_shutdown_script.sh -i 20120713-Scan_list_all.csv -s 90 -S 25 -E 50 -d 10
       
       sh the_grand_shutdown_script.sh -m test -v 2z

      Modes:
        -test
           > Tests connectivity / privelege access to systems, goes no further
        -poweroff
           > Connects to each system and initiates poweroff

      Returns:
        - nix/esx/esxi
           + OK
              > Command executed succesfully
           + NOPING
              > System Didn't reply to ping
           + NORESPONSE
              > System Didn't reply to ssh request
           + CONNECT_SUCCESS_BUT_REMOTE_COMMAND_FAILED_WITH_#
              > Remote command was successful, but return code was not 0
           + PERMISSION_DENIED
              > SSH Keys don't exist
           + SSH_TIMEOUT
              > SSH Failed

        -windows
           + OK
              > Command executed succesfully
           + NT_STATUS_UNSUCCESSFUL
              > 
           + NT_STATUS_ACCOUNT_LOCKED_OUT
              > 
           + NT_STATUS_IO_TIMEOUT
              > 
           + NT_STATUS_TRUSTED_RELATIONSHIP_FAILURE
              > 
           + NT_STATUS_PIPE_NOT_AVAILABLE
              > 
           + NT_STATUS_BAD_NETWORK_NAME
              >
           + NT_STATUS_LOGON_FAILURE
              > 
           + NT_STATUS_REQUEST_NOT_ACCEPTED
              >         
           + LOOKUPFAIL
              > DNS Lookup Failed
           + NOPING
              > System didn't reply to pings
           + UNKNOWN
              > Some network related error occured                          
    "
  }

  function mainMenu()
  { #mainMenu
    echo -e "
     ________         _____                 __
    /_  __/ /  ___   / ___/______ ____  ___/ /
     / / / _ \/ -_) / (_ / __/ _ \`/ _ \/ _  / 
    /_/ /_//_/\__/  \___/_/  \_,_/_//_/\_,_/                                            
          ______        __     __                  ____        _      __ 
         / __/ /  __ __/ /____/ /__ _    _____    / __/_______(_)__  / /_
        _\ \/ _ \/ // / __/ _  / _ \ |/|/ / _ \  _\ \/ __/ __/ / _ \/ __/
       /___/_//_/\_,_/\__/\_,_/\___/__,__/_//_/ /___/\__/_/ /_/ .__/\__/ 
                                                           /_/_/         v$g_version
    ----------------------------Main Menu-------------------------------
    "

    echo "             Input File............$g_poweroffList"
    echo "             Mode..................$g_mode";
    echo "             SSH Timeout...........$g_sshTimeout(s)"
    echo "             Windows Processes.....$g_overlordSpawns_win"
    echo "             Unix Processes........$g_overlordSpawns_nix"
    echo "             ESX Processes.........$g_overlordSpawns_esx"
    echo "             Sleep Kill Delay......$g_sleepDelay(s)"
    echo "             Sleep Kill Delay ESX..$g_sleepDelay_esx(s)"
    
    echo "     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"

  }

  function countSystems()
  { #countSystems

    v_totalSystemsCount=$(cat $g_poweroffList | wc -l)
    v_windowsSystemsCount=$(cat $g_poweroffList | grep -i "windows" | wc -l)
    v_linuxSystemsCount=$(cat $g_poweroffList | grep -i "linux" | wc -l)
    v_esxiSystemsCount=$(cat $g_poweroffList | grep -i "ESXi" | wc -l)
    v_esxSystemsCount=$(cat $g_poweroffList | grep -i "ESX" | wc -l)
    v_AIXSystemsCount=$(cat $g_poweroffList | grep -i "AIX" | wc -l)
    v_SOLARISSystemsCount=$(cat $g_poweroffList | grep -i "SOLARIS" | wc -l)
    v_HPUXSystemsCount=$(cat $g_poweroffList | grep -i "HP-UX" | wc -l)

    echo "             Total Systems.........$v_totalSystemsCount";
    echo "               + Windows Systems...$v_windowsSystemsCount";
    echo "               + Linux Systems.....$v_linuxSystemsCount";
    echo "               + ESXi Systems......$v_esxiSystemsCount";
    echo "               + ESX Systems.......$v_esxSystemsCount";
    echo "               + AIX Systems.......$v_AIXSystemsCount";
    echo "               + Solaris Systems...$v_SOLARISSystemsCount";
    echo "               + HP-UX Systems.....$v_HPUXSystemsCount";

    echo "     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
  }

  function getPermission()
  { #getPermission
    echo ""

    if [ $g_mode = "shutdown" ]; then
      echo "     + Warning: You are currently running in SHUTDOWN mode, any systems in the supplied list WILL be shutdown."
      echo "     + Warning: You are currently running in SHUTDOWN mode, any systems in the supplied list WILL be shutdown."
      echo "     + Warning: You are currently running in SHUTDOWN mode, any systems in the supplied list WILL be shutdown."
      echo "     + Warning: You are currently running in SHUTDOWN mode, any systems in the supplied list WILL be shutdown."                  

    else
      echo ""
    fi

    echo "          *** ARE YOU SURE YOU WANT TO PROCEED? (Y/N) ***"
    read v_choice

    if [ "$v_choice" = "y" -o "$v_choice" = "Y" ];then
      echo ""
    else
      echo "Aborting..."
      echo ""
      exit 0
    fi
  }

  function timer()
  {
      if [[ $# -eq 0 ]]; then
          echo $(date '+%s')
      else
          local  stime=$1
          etime=$(date '+%s')

          if [[ -z "$stime" ]]; then stime=$etime; fi

          dt=$((etime - stime))
          ds=$((dt % 60))
          dm=$(((dt / 60) % 60))
          dh=$((dt / 3600))
          printf '%d:%02d:%02d' $dh $dm $ds
      fi
  }

  function processList()
  { #Split off the lists into different files.

    echo "     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"

    echo "     + Preparing List....."

    # Remove windows line break characters
    echo "          + Converting file from DOS format to Unix...."
      dos2unix -q $g_poweroffList > /dev/null 2>&1

    # run sort -u to sort, and make the list unique
    echo "          + Sorting and making the list unique...."
      sort -u "$g_poweroffList" > /dev/null

    echo "          + Splitting input list into individual pieces...."
    while read v_line
    do
      v_FQDN=`echo ${v_line} | cut -d"," -f1`
      v_OSType=`echo ${v_line} | cut -d"," -f2`
      v_hostType=`echo ${v_line} | cut -d"," -f3`

        if echo "$v_OSType"|grep -i "windows" > /dev/null;then
          a=1
          echo "${v_FQDN}" >>  "$g_windowsHosts"
        elif [ "$v_OSType" = "ESX" ] || [ "$v_OSType" = "esx" ];then
          a=1
          echo "${v_FQDN}" >>  "$g_esxHosts"
        elif echo "$v_OSType"|grep -i "ESXi" > /dev/null;then
          a=1
          echo "${v_FQDN}" >>  "$g_esxiHosts"          
        elif echo "$v_OSType"|grep -i "linux" > /dev/null;then
          a=1
          echo "${v_FQDN}" >>  "$g_linuxHosts"
        elif echo "$v_OSType"|grep -i "AIX" > /dev/null;then
          a=1
          echo "${v_FQDN}" >>  "$g_aixHosts"          
        elif echo "$v_OSType"|grep -i "Solaris" > /dev/null;then
          a=1
          echo "${v_FQDN}" >>  "$g_sunHosts"
        elif echo "$v_OSType"|grep -i "HP-UX" > /dev/null;then
          a=1
          echo "${v_FQDN}" >>  "$g_hpuxHosts"
        fi

      #echo "Processing FQDN: "${v_FQDN}" with IP: "${v_IPAddress}" and OS: "${v_OS}""

    done < "$g_poweroffList"

    echo "     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"    
  }

  function doShutdownLPARs()
  {
    # Call....on all hosts in list.
    echo "          + Shutting Down LPARs...."
    return 0;
  }

  function doShutdown()
  {
    # Call ssh_push.sh <shutdown command> on all hosts in list.
    osType="$1"
    echo "          + Shutting Down Linux Machines...."

    if [ "$osType" = "windows" ];then
      sh ${g_debug} "$g_windowsScript" -g true -m shutdown -local -f "$g_windowsHosts" -s "$g_overlordSpawns_win" -o "$g_windowsLogs" -u "$g_winUsername" -p "$g_winPassword"
    elif [ "$osType" = "esx" ];then
      sh ${g_debug} "$g_sshScript" -f "$g_esxHosts" -c "$g_ESX_shutdownCMD" -g true -o "$g_esxLogs" -d "$g_sleepDelay_esx" -s "$g_overlordSpawns_esx"
    elif [ "$osType" = "esxi" ];then
      sh ${g_debug} "$g_sshScript" -f "$g_esxiHosts" -c "$g_ESXi_shutdownCMD" -g true -o "$g_esxiLogs" -d "$g_sleepDelay_esx" -s "$g_overlordSpawns_esx"
    elif [ "$osType" = "linux" ];then
      sh ${g_debug} "$g_sshScript" -f "$g_linuxHosts" -c "$g_LINUX_shutdownCMD" -g true -o "$g_nixLogs" -d "$g_sleepDelay" -s "$g_overlordSpawns_nix"
    elif [ "$osType" = "aix" ];then
      sh ${g_debug} "$g_sshScript" -f "$g_aixHosts" -c "$g_AIX_shutdownCMD" -g true -o "$g_aixLogs" -d "$g_sleepDelay" -s "$g_overlordSpawns_nix"
    elif [ "$osType" = "solaris" ];then
      sh ${g_debug} "$g_sshScript" -f "$g_sunHosts" -c "$g_SOLARIS_shutdownCMD" -g true -o "$g_sunLogs" -d "$g_sleepDelay" -s "$g_overlordSpawns_nix"
    elif [ "$osType" = "hpux" ];then
      sh ${g_debug} "$g_sshScript" -f "$g_hpuxHosts" -c "$g_HPUX_shutdownCMD" -g true -o "$g_hpuxLogs" -d "$g_sleepDelay" -s "$g_overlordSpawns_nix"
    fi

    return 0;
  }

  function doTest()
  {
    # Run scripts in test capacity to verify Network /SSH / Password connectivity.
    osType="$1"

    if [ "$osType" = "windows" ];then
      sh ${g_debug} "$g_windowsScript" -g true -m test -f "$g_windowsHosts" -s "$g_overlordSpawns_win" -o "$g_windowsLogs" -u "$g_winUsername" -p "$g_winPassword"
    elif [ "$osType" = "esx" ];then
      sh ${g_debug} "$g_sshScript" -f "$g_esxHosts" -c "$g_ESX_testCMD" -g true -o "$g_esxLogs" -d "$g_sleepDelay_esx" -s "$g_overlordSpawns_esx"
    elif [ "$osType" = "esxi" ];then
      sh ${g_debug} "$g_sshScript" -f "$g_esxiHosts" -c "$g_ESXi_testCMD" -g true -o "$g_esxiLogs" -d "$g_sleepDelay_esx" -s "$g_overlordSpawns_esx"
    elif [ "$osType" = "linux" ];then
      sh ${g_debug} "$g_sshScript" -f "$g_linuxHosts" -c "$g_LINUX_testCMD" -g true -o "$g_nixLogs" -d "$g_sleepDelay" -s "$g_overlordSpawns_nix"
    elif [ "$osType" = "aix" ];then
      sh ${g_debug} "$g_sshScript" -f "$g_aixHosts" -c "$g_AIX_testCMD" -g true -o "$g_aixLogs" -d "$g_sleepDelay" -s "$g_overlordSpawns_nix"
    elif [ "$osType" = "solaris" ];then
      sh ${g_debug} "$g_sshScript" -f "$g_sunHosts" -c "$g_SOLARIS_testCMD" -g true -o "$g_sunLogs" -d "$g_sleepDelay" -s "$g_overlordSpawns_nix"
    elif [ "$osType" = "hpux" ];then
      sh ${g_debug} "$g_sshScript" -f "$g_hpuxHosts" -c "$g_HPUX_testCMD" -g true -o "$g_hpuxLogs" -d "$g_sleepDelay" -s "$g_overlordSpawns_nix"
    fi
  }

  function executeJobs()
  {
    # Determine running mode (Either 'test' or 'shutdown')
    if [ "$g_mode" = "test" ];then

        echo "          + Executing TEST commands...."
      if [ -e "$g_esxHosts" ] ; then
          printf '          Elapsed time: %s\n' $(timer $g_tmr)
          echo "     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
          echo '     Executing ESX Tests'
              doTest "esx"
          echo '     Completing ESX Tests'
          echo "     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
      fi   
      if [ -e "$g_esxiHosts" ] ; then
          printf '          Elapsed time: %s\n' $(timer $g_tmr)
          echo "     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"          
          echo '     Executing ESXi Tests'
              doTest "esxi"
          echo '     Completing ESXi Tests'
          echo "     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"          
      fi
      if [ -e "$g_aixHosts" ] ; then
          printf '          Elapsed time: %s\n' $(timer $g_tmr)
          echo "     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"          
          echo '     Executing AIX Tests'        
              doTest "aix"
          echo '     Completing AIX Tests'
          echo "     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"          
      fi      
      if [ -e "$g_windowsHosts" ] ; then
          printf '          Elapsed time: %s\n' $(timer $g_tmr)
          echo "     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"          
          echo '     Executing Windows Tests'
              doTest "windows"
          echo '     Completing Windows Tests'
          echo "     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"          
      fi      
      if [ -e "$g_linuxHosts" ] ; then
          printf '          Elapsed time: %s\n' $(timer $g_tmr)
          echo "     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"          
          echo '     Executing Linux Tests'
              doTest "linux"
          echo '     Completing Linux Tests'
          echo "     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"          
      fi    
      if [ -e "$g_sunHosts" ] ; then
          printf '          Elapsed time: %s\n' $(timer $g_tmr)
          echo "     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"          
          echo '     Executing Solaris Tests'        
              doTest "solaris"
          echo '     Completing Solaris Tests'
          echo "     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"          
      fi    
      if [ -e "$g_hpuxHosts" ] ; then
          printf '          Elapsed time: %s\n' $(timer $g_tmr)
          echo "     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
          echo '     Executing HP-UX Tests'        
              doTest "hpux"
          echo '     Completing HP-UX Tests'
          echo "     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"          
      fi    
                                
    elif [ "$g_mode" = "shutdown" ];then
        echo "          + Executing SHUTDOWN commands...."
      if [ -e "$g_esxHosts" ] ; then
          printf '          Elapsed time: %s\n' $(timer $g_tmr)
          echo "     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
          echo '     Executing ESX Shutdown'
              doShutdown "esx"
          echo '     Completing ESX Shutdown'
          echo "     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
      fi   
      if [ -e "$g_esxiHosts" ] ; then
          printf '          Elapsed time: %s\n' $(timer $g_tmr)
          echo "     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"          
          echo '     Executing ESXi Shutdown'
              doShutdown "esxi"
          echo '     Completing ESXi Shutdown'
          echo "     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"          
      fi
      if [ -e "$g_aixHosts" ] ; then
          printf '          Elapsed time: %s\n' $(timer $g_tmr)
          echo "     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"          
          echo '     Executing AIX Shutdown'        
              doShutdown "aix"
          echo '     Completing AIX Shutdown'
          echo "     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"          
      fi          
      if [ -e "$g_windowsHosts" ] ; then
          printf '          Elapsed time: %s\n' $(timer $g_tmr)
          echo "     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"          
          echo '     Executing Windows Shutdown'
              doShutdown "windows"
          echo '     Completing Windows Shutdown'
          echo "     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"          
      fi      
      if [ -e "$g_linuxHosts" ] ; then
          printf '          Elapsed time: %s\n' $(timer $g_tmr)
          echo "     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"          
          echo '     Executing Linux Shutdown'
              doShutdown "linux"
          echo '     Completing Linux Shutdown'
          echo "     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"          
      fi    
      if [ -e "$g_sunHosts" ] ; then
          printf '          Elapsed time: %s\n' $(timer $g_tmr)
          echo "     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"          
          echo '     Executing Solaris Shutdown'        
              doShutdown "solaris"
          echo '     Completing Solaris Shutdown'
          echo "     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"          
      fi    
      if [ -e "$g_hpuxHosts" ] ; then
          printf '          Elapsed time: %s\n' $(timer $g_tmr)
          echo "     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
          echo '     Executing HP-UX Shutdown'        
              doShutdown "hpux"
          echo '     Completing HP-UX Shutdown'
          echo "     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"          
      fi  
    else
      echo "Invalid mode specified"
      exit
    fi

  }

  function getSpaces()
  {
    COUNTER=0
    RANDOMVAR=""

    while [ ${COUNTER} -lt ${1} ];
    do
      RANDOMVAR="${RANDOMVAR}."
      let COUNTER=COUNTER+1
    done

  eval iperiods="${RANDOMVAR}";

  }


  function tallyResults()
  { #tallyResults
        


    echo "     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
      
      v_ALL=$(cat ${g_PWD}/lists/*.csv | wc -l)
        echo "     Total Systems Scanned.....$v_ALL"

      array=( OK NOPING NORESPONSE CONNECT_SUCCESS_BUT_REMOTE_COMMAND_FAILED_WITH PERMISSION_DENIED SSH_TIMEOUT NT_STATUS_UNSUCCESSFUL NT_STATUS_ACCOUNT_LOCKED_OUT NT_STATUS_IO_TIMEOUT NT_STATUS_TRUSTED_RELATIONSHIP_FAILURE NT_STATUS_PIPE_NOT_AVAILABLE NT_STATUS_BAD_NETWORK_NAME NT_STATUS_LOGON_FAILURE NT_STATUS_REQUEST_NOT_ACCEPTED NT_STATUS_NO_LOGON_SERVERS NT_STATUS_DUPLICATE_NAME LOOKUPFAIL UNKNOWN)
      for i in "${array[@]}"
      do
        VARSUM=$(( 50 - $((${#i} )) ))
        v_COUNT=$(cat ${g_PWD}/logs/${g_DT}*.csv | grep -i "$i" | wc -l)
        
        getSpaces ${VARSUM} ${iperiods};

        if [ $v_COUNT != "0" ];then
          v_PERCENT=`echo "scale=4;$v_COUNT / $v_ALL*100" | bc -l` > /dev/null
          v_PERCENT=$(echo "$v_PERCENT" | awk ' sub("\\.*0+$","") ')
          echo "  ${i}${iperiods}${v_COUNT}  (${v_PERCENT}%)"
        fi
      done

    echo "     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"

           
  } 

  function askTally()
  { #askTally
    echo ""
    echo ""
    echo ""
    echo "          *** Would you like to consolidate lists? (Y/N) ***"
    read v_choice

    if [ "$v_choice" = "y" -o "$v_choice" = "Y" ];then
      echo "                     Consolidating..."

        if [ -e "$g_esxLogs" ] ; then
            cat ${g_PWD}/logs/${g_DT}*esxLogs.csv >> ${g_PWD}/logs/${g_DT}-compact_esx.csv
            cat ${g_PWD}/logs/${g_DT}*esxLogs.csv.full >> ${g_PWD}/logs/${g_DT}-full_esx.csv

            rm -f ${g_PWD}/logs/${g_DT}*esxLogs.csv
            rm -f ${g_PWD}/logs/${g_DT}*esxLogs.csv.full                
        fi

        if [ -e "$g_esxiLogs" ] ; then  
            cat ${g_PWD}/logs/${g_DT}*esxiLogs.csv >> ${g_PWD}/logs/${g_DT}-compact_esx.csv
            cat ${g_PWD}/logs/${g_DT}*esxiLogs.csv.full >> ${g_PWD}/logs/${g_DT}-full_esx.csv 

            rm -f ${g_PWD}/logs/${g_DT}*esxiLogs.csv
            rm -f ${g_PWD}/logs/${g_DT}*esxiLogs.csv.full                     
        fi

        if [ -e "$g_nixLogs" ] ; then
            cat ${g_PWD}/logs/${g_DT}*nixLogs.csv >> ${g_PWD}/logs/${g_DT}-compact_nix.csv
            cat ${g_PWD}/logs/${g_DT}*nixLogs.csv.full >> ${g_PWD}/logs/${g_DT}-full_nix.csv

            rm -f ${g_PWD}/logs/${g_DT}*nixLogs.csv
            rm -f ${g_PWD}/logs/${g_DT}*nixLogs.csv.full                
        fi

        if [ -e "$g_aixLogs" ] ; then
            cat ${g_PWD}/logs/${g_DT}*aixLogs.csv >> ${g_PWD}/logs/${g_DT}-compact_nix.csv
            cat ${g_PWD}/logs/${g_DT}*aixLogs.csv.full >> ${g_PWD}/logs/${g_DT}-full_nix.csv

            rm -f ${g_PWD}/logs/${g_DT}*aixLogs.csv
            rm -f ${g_PWD}/logs/${g_DT}*aixLogs.csv.full                
        fi

        if [ -e "$g_sunLogs" ] ; then
          cat ${g_PWD}/logs/${g_DT}*sunLogs.csv >> ${g_PWD}/logs/${g_DT}-compact_nix.csv
          cat ${g_PWD}/logs/${g_DT}*sunLogs.csv.full >> ${g_PWD}/logs/${g_DT}-full_nix.csv

          rm -f ${g_PWD}/logs/${g_DT}*sunLogs.csv
          rm -f ${g_PWD}/logs/${g_DT}*sunLogs.csv.full               
        fi

        if [ -e "$g_hpuxLogs" ] ; then
          cat ${g_PWD}/logs/${g_DT}*hpuxLogs.csv >> ${g_PWD}/logs/${g_DT}-compact_nix.csv
          cat ${g_PWD}/logs/${g_DT}*hpuxLogs.csv.full >> ${g_PWD}/logs/${g_DT}-full_nix.csv    

          rm -f ${g_PWD}/logs/${g_DT}*hpuxLogs.csv
          rm -f ${g_PWD}/logs/${g_DT}*hpuxLogs.csv.full         
        fi

        zipIt
    else
      echo "                     Skipping..."
      echo ""
      exit 0
    fi
  }

  function zipIt()
  { #zipit
    echo ""
    echo ""
    echo ""
    echo "          *** Would you like to zip the lists? (Y/N) ***"
    read v_choice

    if [ "$v_choice" = "y" -o "$v_choice" = "Y" ];then
      echo "                     Zipping..."

        zip -q logs/${g_DT}-ScanResults ${g_PWD}/logs/${g_DT}*
    else
      echo "                     Skipping..."
      echo ""
      exit 0
    fi
  }  
#----END Functions---------------------------------------------------------------------------------#



#---Main---------------------------------------------------------------------------------------#

#----------------------------------------------------------------------------------------------#
if [ "$(id -u)" != "0" ] ; then echo "Run as root"; exit; fi

#----------------------------------------------------------------------------------------------#
while getopts "i:t:m:b:s:S:E:d:D:xpv?" OPTIONS; do
   case ${OPTIONS} in
      i ) g_poweroffList=$OPTARG ;;
      m ) g_mode=$OPTARG ;;
      p ) g_ping="true" ;;
      x ) g_debug="-x" ;;
      b ) g_benchmark=$OPTARG ;;
      l ) g_logFile=$OPTARG ;;
      t ) g_sshTimeout=$OPTARG ;;
      d ) g_sleepDelay=$OPTARG ;;
      D ) g_sleepDelay_esx=$OPTARG ;;
      s ) g_overlordSpawns_win=$OPTARG ;;
      S ) g_overlordSpawns_nix=$OPTARG ;;
      E ) g_overlordSpawns_esx=$OPTARG ;;
      v ) verbose=$OPTARG ;;
      ? ) help ; exit ;;
      * ) echo "Unknown option" 1>&2; help; exit 2 ;; # Default
   esac
done
if [ ! -e "/usr/bin/mktemp" ] && [ ! -e "/bin/mktemp" ] ; then
   echo "mktemp isn't installed";
   exit
fi

if [ ! -e "/usr/bin/net" ] && [ ! -e "/usr/sbin/net" ] ; then
   echo "net isn't installed";
   exit
fi

if [ ! -e "/usr/bin/test" ] && [ ! -e "/usr/sbin/test" ] ; then
   echo "test isn't installed";
   exit
fi

if [ ! -e "/usr/bin/ssh" ] && [ ! -e "/usr/sbin/ssh" ] ; then
   echo "ssh isn't installed";
   exit
fi

if [ ! -e "/usr/bin/dos2unix" ] && [ ! -e "/usr/sbin/dos2unix" ] ; then
   echo "dos2unix isn't installed";
   exit
fi

  #Start time (to determine execution time)
  g_tmr=$(timer)

mainMenu
countSystems
getPermission

# split off the lists.
processList

executeJobs
tallyResults
askTally

if [ $g_mode = "shutdown" ]; then
  echo "          Aaaaaaaaaaaannnnnnnnnnndddddddddddddddddddddddddddddd It's gone.............."
  echo "          Aaaaaaaaaaaannnnnnnnnnndddddddddddddddddddddddddddddd It's gone.............."
  echo "          Aaaaaaaaaaaannnnnnnnnnndddddddddddddddddddddddddddddd It's gone.............."
  echo "          Aaaaaaaaaaaannnnnnnnnnndddddddddddddddddddddddddddddd It's gone.............."
  echo "          Aaaaaaaaaaaannnnnnnnnnndddddddddddddddddddddddddddddd It's gone.............."        
else
  echo "          Testing Complete...."
fi
  printf '          Elapsed time: %s\n' $(timer $g_tmr)


#----------------------------------------------------------------------------------------------#
if [ "$diagnostics" == "true" ] ; then
   echo "-Settings------------------------------------------------------------------------------------
             mode=$g_mode
      diagnostics=$v_diagnostics
          verbose=$v_verbose
            debug=$v_debug
               os=$os
-Environment---------------------------------------------------------------------------------" >> $g_logFile
   display diag "Detecting: Kernel"
   uname -a >> $g_logFile
fi



#---Ideas/Notes/DumpPad------------------------------------------------------------------------#
# Keep notes down here for future ideas, bug fixes, etc.
#Fix   - Add Some Fixing Logic
#Check - add some checking logic
#Ideas - Add some new ideas
