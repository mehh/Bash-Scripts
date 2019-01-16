#! /bin/bash
#----------------------------------------------------------------------------------------------#
# ssl-check.sh v1.0 (#0 2017-08-23)                                                            #
#                                                                                              #
# This script will loop through all domains                                                    #
# and will let you know if the SSL Certs are expiring                                          #
############################## Modification Log ##############################                 #
# Date          Who             Version         Description                                    #
# 20170823      KChase          1.0             Initial Release                                #

v_Domain="krischase.com";
RECIPIENT="hostmaster@mysite.example.net";
DAYS=45;
echo "Checking if $TARGET expires in less than $DAYS days";
expirationdate=`echo | openssl s_client -connect ${v_Domain}:443 -servername ${v_Domain} 2>/dev/null | openssl x509 -noout -enddate|awk -F'notAfter=' '{print $2}'`

getmonth()
{
       LOWER=`tolower $1`

       case ${LOWER} in
             jan) echo 1 ;;
             feb) echo 2 ;;
             mar) echo 3 ;;
             apr) echo 4 ;;
             may) echo 5 ;;
             jun) echo 6 ;;
             jul) echo 7 ;;
             aug) echo 8 ;;
             sep) echo 9 ;;
             oct) echo 10 ;;
             nov) echo 11 ;;
             dec) echo 12 ;;
               *) echo  0 ;;
       esac
}




in7days=$(($(date +%s) + (86400*$DAYS)));
if [ $in7days -gt $expirationdate ]; then
    echo "KO - Certificate for $TARGET expires in less than $DAYS days, on $(date -d @$expirationdate '+%Y-%m-%d')" \
    | mail -s "Certificate expiration warning for $TARGET" $RECIPIENT ;
else
    echo "OK - Certificate expires on $expirationdate";
fi;