#! /bin/bash
#----------------------------------------------------------------------------------------------#
# sonos-shhh.sh v1.0 (#0 2017-08-23)                                                           #
#                                                                                              #
# This script will monitor and adjust sonos volume                                             #
############################## Modification Log ##############################                 #
# Date          Who             Version         Description                                    #
# 20171004      KChase          1.0             Initial Release                                #

#   Depends on sonos-cli (https://github.com/bencevans/sonos-cli)
#   npm install --global sonos-cli
#
#   Must obtain zone prior to invoking this script
#   `sonos-cli list-zones`

#################################
### Start of main program
#################################
while getopts m:v:z:h option
do
    case "${option}"
    in
        m) v_MaxVolume=${OPTARG};;
        z) v_Zone=${OPTARG};;
        h) usage
           exit 1;;
       \?) usage
           exit 1;;
    esac
done

# Make sure sonos-cli exists
sonos-cli -v foo >/dev/null 2>&1 || { echo "I require sonos-cli but it's not installed.  Aborting." >&2; exit 1; }

# Make sure zone exists
sonos-cli --zone "${v_Zone}" volume &> /dev/null

if [ $? -eq 1 ]
then
  echo "Could not locate zone"
  exit 1;
fi

echo "Checking if volume is above threshold..."
v_CurrentVolume=`sonos-cli --zone "${v_Zone}" volume`

echo "Max Volume:${v_MaxVolume}";
echo "Current Volume:${v_CurrentVolume}";

if [ "${v_CurrentVolume}" -gt "${v_MaxVolume}" ]; then
    echo "Volume is too high!"
    sonos-cli --zone ${v_Zone} volume ${v_MaxVolume}
    exit 0;
else
    echo "Volume Okay!"
    exit 0;
fi
