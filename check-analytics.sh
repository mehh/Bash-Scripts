#! /bin/bash
#----------------------------------------------------------------------------------------------#
# check-googleAnalytics.sh v1.0 (#0 2016-05-05)                                                #
#                                                                                              #
# This script will loop through all users on WHM server,                                       #
# retreive associated domains and add them to Uptime Robot                                     #
############################## Modification Log ##############################                 #
# Date          Who             Version         Description                                    #
# 20160505      KChase          1.0             Initial Release                                #

#################################
### Start of main program
#################################
while getopts d:f:h option
do
    case "${option}"
    in
        d) v_DOMAIN=${OPTARG};;
        h) usage
           exit 1;;
       \?) usage
           exit 1;;
    esac
done

# Check if google analytics code is installed, if so retrieve UA code

v_RESPONSEFILE=`curl --silent ${v_DOMAIN}`

tagFound=`echo ${v_RESPONSEFILE} | grep 'GoogleAnalyticsObject' | awk -F', ' '{ print $2 }'|cut -d"'" -f2 2>&1`

if [[ x"${?}" == x"0" ]]
then
    v_analyticsString=`echo ${v_RESPONSEFILE} | grep 'GoogleAnalyticsObject' | awk -F', ' '{ print $2 }'|cut -d"'" -f2 2>&1`
else
    v_analyticsString="None"
fi


echo ${v_analyticsString}