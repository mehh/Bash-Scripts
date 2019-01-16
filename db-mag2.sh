#!/bin/bash
#   Script used to run a search and replace on a WordPress database
#
#   This script will go out and:
#       Download the DBSR script    
#       Unzip it
#       Move it's working directory
#       Run a database search and replace
#       Clean up after itself
#
#

    #   Setup function for help
    help()
    {
        echo "      Usage: db-wp.sh [-s search] [-r replace]"
        echo "      -s search : What to search for"
        echo "      -r replace : What to replace with"
        echo " "
        exit 1
    }

    while getopts "s:r:h" OPTIONS; do
       case ${OPTIONS} in
          s ) v_SEARCH=$OPTARG ;;
          r ) v_REPLACE=$OPTARG ;;
          h ) help ;;
          * ) echo "Unknown option" 1>&2; help; exit 2 ;; # Default
       esac
    done

    if [ -z "${v_SEARCH}" ] || [ -z "${v_REPLACE}" ]; then
        help
    fi

echo 'Starting DBSR'

echo "++ Would you like to download dbsr [Y/n]"
read v_Answer

if [[ "$v_Answer" = "Y" ]]; then
    wget –quiet https://github.com/interconnectit/Search-Replace-DB/archive/master.zip
    unzip master.zip
    v_Number=`echo $RANDOM`;
    mv Search-Replace-DB-master/ dbsr-${v_Number}

else
    #   Can't search and replace without the script
    exit;
fi;


echo 'Setting DB Connection values'
v_DBHOST=`cat app/etc/env.php | grep "'host'" | cut -d "'" -f4`;
v_DBNAME=`cat app/etc/env.php | grep "'dbname'" | cut -d "'" -f4`;
v_DBUSER=`cat app/etc/env.php | grep "'username'" | cut -d "'" -f4`;
v_DBPASS=`cat app/etc/env.php | grep "'password'" | cut -d "'" -f4`;

echo 'Replacing DB Values'
php dbsr-${v_Number}/srdb.cli.php -u ${v_DBUSER} -h ${v_DBHOST} -p${v_DBPASS} -n ${v_DBNAME} -s "${v_SEARCH}" -r "${v_REPLACE}"


echo -n '++ Would you like to delete the dbsr folder? [Y/n]'
read v_Answer

if [[ x"${v_Answer}" == x"Y" ]]; then
    v_Delete=`rm -rf dbsr-${v_Number}/ master.zip`

fi;

rm -rf index.html