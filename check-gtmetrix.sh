#! /bin/bash
#----------------------------------------------------------------------------------------------#
# check-gtmetrix.sh v1.0 (#0 2016-05-05)                                                       #
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
        d) DOMAIN=${OPTARG};;
        h) usage
           exit 1;;
       \?) usage
           exit 1;;
    esac
done

    #gtmetrix API info
    export g_GTMETRIX_USER=''
    export g_GTMETRIX_KEY=''

    # Using gtmatrix API, we will scan the site for page load speed information / grades
    echo '++  Checking page speed / score using gtMetrix';

    test_id=`curl --silent --user ${g_GTMETRIX_USER}:${g_GTMETRIX_KEY} --form url=${DOMAIN} --form x-metrix-adblock=0 https://gtmetrix.com/api/0.1/test | jq -r .test_id`
    state="Unknown"
    loop_run_time_secs=0

    while [[ "$state" != "completed" && $loop_run_time_secs < 60 ]]
    do
        results=`curl --silent --user ${g_GTMETRIX_USER}:${g_GTMETRIX_KEY} https://gtmetrix.com/api/0.1/test/$test_id`
        state=`echo $results | jq -r .state`
        echo "${state} ...\r"
        sleep 6
        loop_run_time_secs=$((loop_run_time_secs + 6))
    done

    page_load_time=`echo $results | jq -r .results.page_load_time`
    html_bytes=`echo $results | jq -r .results.html_bytes`
    page_elements=`echo $results | jq -r .results.page_elements`
    report_url=`echo $results | jq -r .results.report_url`
    html_load_time=`echo $results | jq -r .results.html_load_time`
    page_bytes=`echo $results | jq -r .results.page_bytes`
    pagespeed_score=`echo $results | jq -r .results.pagespeed_score`
    yslow_score=`echo $results | jq -r .results.yslow_score`

echo "date,site,page_load_time,html_bytes,page_elements,html_load_time,page_bytes,pagespeed_score,yslow_score,report_url"
echo "`date`,$site,$page_load_time,$html_bytes,$page_elements,$html_load_time,$page_bytes,$pagespeed_score,$yslow_score,$report_url"