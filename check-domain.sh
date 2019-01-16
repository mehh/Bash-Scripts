#! /bin/bash
#----------------------------------------------------------------------------------------------#
# domain-check.sh v1.0 (#0 2017-08-23)                                                         #
#
# # Fork Of http://www.cyberciti.biz/files/scripts/domain-check-2.txt                                                                                                                                                                                           #
# This script will loop through all domains                                                    #
# and will let you know if the domains are expiring                                            #
############################## Modification Log ##############################                 #
# Date          Who             Version         Description                                    #
# 20170823      KChase          1.0             Initial Release                                #

PATH=/bin:/usr/bin:/usr/local/bin:/usr/local/ssl/bin:/usr/sfw/bin
export PATH

# Who to page when an expired domain is detected (cmdline: -e)
ADMIN="kris@krischase.com"

# Number of days in the warning threshhold  (cmdline: -x)
WARNDAYS=30

# If QUIET is set to TRUE, don't print anything on the console (cmdline: -q)
QUIET="FALSE"

# Don't send emails by default (cmdline: -a)
ALARM="FALSE"

# Whois server to use (cmdline: -s)
WHOIS_SERVER="whois.internic.org"

# Location of system binaries
AWK=`which awk`
WHOIS=`which whois`
DATE=`which date`
CUT=`which cut`
TR=`which tr`
MAIL=`which mail`

# Place to stash temporary files
WHOIS_TMP="/var/tmp/whois.$$"

#############################################################################
# Purpose: Convert a date from MONTH-DAY-YEAR to Julian format
# Acknowledgements: Code was adapted from examples in the book
#                   "Shell Scripting Recipes: A Problem-Solution Approach"
#                   ( ISBN 1590594711 )
# Arguments:
#   $1 -> Month (e.g., 06)
#   $2 -> Day   (e.g., 08)
#   $3 -> Year  (e.g., 2006)
#############################################################################
date2julian()
{
    if [ "${1} != "" ] && [ "${2} != ""  ] && [ "${3}" != "" ]
    then
         ## Since leap years add aday at the end of February,
         ## calculations are done from 1 March 0000 (a fictional year)
         d2j_tmpmonth=$((12 * ${3} + ${1} - 3))

         ## If it is not yet March, the year is changed to the previous year
         d2j_tmpyear=$(( ${d2j_tmpmonth} / 12))

         ## The number of days from 1 March 0000 is calculated
         ## and the number of days from 1 Jan. 4713BC is added
         echo $(( (734 * ${d2j_tmpmonth} + 15) / 24 -  2 * ${d2j_tmpyear} + ${d2j_tmpyear}/4
                       - ${d2j_tmpyear}/100 + ${d2j_tmpyear}/400 + $2 + 1721119 ))
    else
         echo 0
    fi
}

#############################################################################
# Purpose: Convert a string month into an integer representation
# Arguments:
#   $1 -> Month name (e.g., Sep)
#############################################################################
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

#############################################################################
# Purpose: Calculate the number of seconds between two dates
# Arguments:
#   $1 -> Date #1
#   $2 -> Date #2
#############################################################################
date_diff()
{
        if [ "${1}" != "" ] &&  [ "${2}" != "" ]
        then
                echo $(expr ${2} - ${1})
        else
                echo 0
        fi
}

##################################################################
# Purpose: Converts a string to lower case
# Arguments:
#   $1 -> String to convert to lower case
##################################################################
tolower()
{
     LOWER=`echo ${1} | ${TR} [A-Z] [a-z]`
     echo $LOWER
}

##################################################################
# Purpose: Access whois data to grab the registrar and expiration date
# Arguments:
#   $1 -> Domain to check
##################################################################
check_domain_status()
{
    local REGISTRAR=""
    # Avoid WHOIS LIMIT EXCEEDED - slowdown our whois client by adding 3 sec
    sleep 3
    # Save the domain since set will trip up the ordering
    DOMAIN=${1}
    TLDTYPE="`echo ${DOMAIN} | ${CUT} -d '.' -f3 | tr '[A-Z]' '[a-z]'`"
    if [ "${TLDTYPE}"  == "" ];
    then
        TLDTYPE="`echo ${DOMAIN} | ${CUT} -d '.' -f2 | tr '[A-Z]' '[a-z]'`"
    fi

    # Invoke whois to find the domain registrar and expiration date
    #${WHOIS} -h ${WHOIS_SERVER} "=${1}" > ${WHOIS_TMP}
    # Let whois select server
    ${WHOIS} "${1}" > ${WHOIS_TMP}

    # Parse out the expiration date and registrar -- uses the last registrar it finds

    REGISTRAR=`cat ${WHOIS_TMP} | ${AWK} -F: '/Registrar:/ && $2 != "" { REGISTRAR=substr($2,0,22) } END { print REGISTRAR }'`

    # If the Registrar is NULL, then we didn't get any data
    if [ "${REGISTRAR}" = "" ]
    then
        prints "$DOMAIN" "Unknown" "Unknown" "Unknown" "Unknown"
        return
    fi

    # The whois Expiration data should resemble the following: "Expiration Date: 09-may-2008"

    DOMAINDATE=`cat ${WHOIS_TMP} | ${AWK} '/Registry Expiry Date:/ { print $4 }'| ${AWK} -F'T' '{print $1}'`

    # echo "DomainDate: $DOMAINDATE" # debug
    # Whois data should be in the following format: "13-feb-2006"


    v_DomainMonth=`echo ${DOMAINDATE} | awk -F'-' '{print $2}'`
    v_DomainDay=`echo ${DOMAINDATE} | awk -F'-' '{print $3}'`
    v_DomainYear=`echo ${DOMAINDATE} | awk -F'-' '{print $1}'`



    # Convert the date to seconds, and get the diff between NOW and the expiration date
    NOWJULIAN=$(date2julian ${MONTH#0} ${DAY#0} ${YEAR})

    DOMAINJULIAN=$(date2julian ${v_DomainMonth#0} ${v_DomainDay#0} ${v_DomainYear})
    DOMAINDIFF=$(date_diff ${NOWJULIAN} ${DOMAINJULIAN})

    # echo " "
    # echo "NOWJULIAN ${NOWJULIAN} "
    # echo "DOMAINJULIAN ${DOMAINJULIAN}"
    # echo "DOMAINDIFF ${DOMAINDIFF}"


    if [ ${DOMAINDIFF} -lt 0 ]
    then
          if [ "${ALARM}" = "TRUE" ]
          then
                echo "The domain ${DOMAIN} has expired!" \
                | ${MAIL} -s "Domain ${DOMAIN} has expired!" ${ADMIN}
           fi

           prints "${DOMAIN}" "Expired" "${DOMAINDATE}" "${DOMAINDIFF}" "${REGISTRAR}"

    elif [ ${DOMAINDIFF} -lt ${WARNDAYS} ]
    then
           if [ "${ALARM}" = "TRUE" ]
           then
                    echo "The domain ${DOMAIN} will expire on ${DOMAINDATE}" \
                    | ${MAIL} -s "Domain ${DOMAIN} will expire in ${WARNDAYS}-days or less" ${ADMIN}
            fi
            prints "${DOMAIN}" "Expiring" "${DOMAINDATE}" "${DOMAINDIFF}" "${REGISTRAR}"
     else
            prints "${DOMAIN}" "Valid" "${DOMAINDATE}"  "${DOMAINDIFF}" "${REGISTRAR}"
     fi
}

####################################################
# Purpose: Print a heading with the relevant columns
# Arguments:
#   None
####################################################
print_heading()
{
        if [ "${QUIET}" != "TRUE" ]
        then
                printf "\n%-35s %-46s %-8s %-11s %-5s\n" "Domain" "Registrar" "Status" "Expires" "Days Left"
                echo "----------------------------------- ---------------------------------------------- -------- ----------- ---------"
        fi
}

#####################################################################
# Purpose: Print a line with the expiraton interval
# Arguments:
#   $1 -> Domain
#   $2 -> Status of domain (e.g., expired or valid)
#   $3 -> Date when domain will expire
#   $4 -> Days left until the domain will expire
#   $5 -> Domain registrar
#####################################################################
prints()
{
    if [ "${QUIET}" != "TRUE" ]
    then
            MIN_DATE=$(echo $3 | ${AWK} '{ print $1, $2, $4 }')
            printf "%-35s %-46s %-8s %-11s %-5s\n" "$1" "$5" "$2" "$MIN_DATE" "$4"
    fi
}

##########################################
# Purpose: Describe how the script works
# Arguments:
#   None
##########################################
usage()
{
        echo "Usage: $0 [ -e email ] [ -x expir_days ] [ -q ] [ -a ] [ -h ]"
        echo "          {[ -d domain_namee ]} || { -f domainfile}"
        echo ""
        echo "  -a               : Send a warning message through email "
        echo "  -d domain        : Domain to analyze (interactive mode)"
        echo "  -e email address : Email address to send expiration notices"
        echo "  -f domain file   : File with a list of domains"
        echo "  -h               : Print this screen"
        echo "  -s whois server  : Whois sever to query for information"
        echo "  -q               : Don't print anything on the console"
        echo "  -x days          : Domain expiration interval (eg. if domain_date < days)"
        echo ""
}

### Evaluate the options passed on the command line
while getopts ae:f:hd:s:qx: option
do
        case "${option}"
        in
                a) ALARM="TRUE";;
                e) ADMIN=${OPTARG};;
                d) DOMAIN=${OPTARG};;
                f) SERVERFILE=$OPTARG;;
                s) WHOIS_SERVER=$OPTARG;;
                q) QUIET="TRUE";;
                x) WARNDAYS=$OPTARG;;
                \?) usage
                    exit 1;;
        esac
done

### Check to see if the whois binary exists
if [ ! -f ${WHOIS} ]
then
        echo "ERROR: The whois binary does not exist in ${WHOIS} ."
        echo "  FIX: Please modify the \$WHOIS variable in the program header."
        exit 1
fi

### Check to make sure a date utility is available
if [ ! -f ${DATE} ]
then
        echo "ERROR: The date binary does not exist in ${DATE} ."
        echo "  FIX: Please modify the \$DATE variable in the program header."
        exit 1
fi

### Baseline the dates so we have something to compare to
MONTH=$(${DATE} "+%m")
DAY=$(${DATE} "+%d")
YEAR=$(${DATE} "+%Y")
NOWJULIAN=$(date2julian ${MONTH#0} ${DAY#0} ${YEAR})

### Touch the files prior to using them
touch ${WHOIS_TMP}

### If a HOST and PORT were passed on the cmdline, use those values
if [ "${DOMAIN}" != "" ]
then
        print_heading
        check_domain_status "${DOMAIN}"
### If a file and a "-a" are passed on the command line, check all
### of the domains in the file to see if they are about to expire
elif [ -f "${SERVERFILE}" ]
then
        print_heading
        while read DOMAIN
        do
                check_domain_status "${DOMAIN}"

        done < ${SERVERFILE}

### There was an error, so print a detailed usage message and exit
else
        usage
        exit 1
fi

# Add an extra newline
echo

### Remove the temporary files
#rm -f ${WHOIS_TMP}

### Exit with a success indicator
exit 0