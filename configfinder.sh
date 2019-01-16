#!/bin/bash
# Get user passwords from config files, for when they get set to random strings due to the old hashes.
# simple and such.
# original script dlau@liquidweb.com
# mysql user perm addition hackery abrevick@liquidweb.com
# feature requests, bug reports to https://git.sysres.liquidweb.com/sysres/configfinder/issues

VERSION="3.13"

txtgrn='\e[0;32m' # Green
txtrst='\e[0m'    # Text Reset
txtylw='\e[0;33m' # Yellow
txtred='\e[0;31m' # this right here is red.
bgred='\e[41m'
txtwht='\e[0;37m'

passfile=/root/mysqlpw
conffilelocations=/root/configs.cms.txt
thisscript=`basename $0`
userlist=""
Verbose=0
#setup string for searching files here.
conffilelist="wp-config.php
configuration.php
local.xml
systemComponent.php
settings.php
configure.php"

unset first
for file in $conffilelist; do
 if [[ -z $first ]];then
   findparam="-name $file"
 else
   findparam="$findparam -or -name $file"
 fi
 first="set"
done


function info(){
    echo -e "${txtgrn}$@${txtrst}"
}

function warn(){
    echo -e "${txtylw}$@ $txtrst"
}

function threaten() {
    echo -e "${txtred}*** ${txtwht}${bgred}$@${txtrst}${txtred} ***${txtrst}"
}


function print_help(){
    cat << EOF

    $thisscript  [version: $VERSION]

    search CMS configurations for what-should-be the correct passwords.

    currently looks for:
    Wordpress, joomla, Magento, osCommerce.

    -- options --
    -userlist   Specify a userlist to check against. Can be a single user, list in quotes, a file containing the usernames, or 'all'

            example:
            $thisscript -userlist joe
            $thisscript -userlist "user1 user2"
            $thisscript -userlist /root/userlist.txt
            $thisscript -userlist all

        Creates two files: $passfile $conffilelocations

    -fixmysql   Add mysql user, update password, assign to database, assign to cpanel user for found databases, run in conjuction with userlist.

            $thisscript -fixmysql -userlist bob

    -justfix   Just process a found $passfile
    -v        be verbose.
    -help        this.

EOF

}

function explode_if_shared() {
 if $(hostname | grep -q .liquidweb.com) ; then
     warn "this is a shared server right? I'm not participating in this."
     exit
 fi
}

function write_creds() {
        local user=$1
        local pass=$2
        local db=$3
        local cpuser=$4
        local file=$5
        if [ -z "$(echo $user)" ]; then return ; fi
        if [[ "$user" =~ "root" ]] ; then return ; fi
        if [ -z "$(echo $pass)" ] ; then return ; fi
        echo "$user $pass $db $cpuser $file" >> $passfile
}

function find_users_hosts() {
    local $USER=$1
    local hosts=`mysql -B -N -e "select host from mysql.user where user='$USER';"`
    echo "$hosts"
}


function mysql_userfix() {
    local USER=$1
    local PASS=$2
    #next will be either mysql username, or blank
    local usercheck=`mysql mysql -B -N -e "select user from user where user='$USER' and host='localhost';"`
    #test if user exists
    if [[ "$USER" == "$usercheck" ]]; then
        #set for other db 'hosts'? could also get them from config file?
        hosts=`find_users_hosts $USER`
        for HOST in $hosts; do
            #update password for user if it exists,
            mysql -e "SET SESSION old_passwords=FALSE; set PASSWORD for '$USER'@'$HOST' = PASSWORD('$PASS');"
        done
    else
        #create missing user
        mysql -e "create user '$USER'@'localhost' identified by '$PASS'; "
    fi
}

function mysql_perms() {
    local USER=$1
    local PASS=$2
    local DB=$3
    local CPUSER=$4
    local file=$5
    info  "processing user: $USER pass: $PASS db: $DB cpuser: $CPUSER"
    # FAIL if root user!
    if [[ ! "$USER" == "root" ]]; then

        mysql_userfix "$USER" "$PASS"

        #create DB (if needed)
        if mysqlshow "$DB" > /dev/null 2>&1 ; then
           mysqladmin create "$DB"
        fi

        #grant perms on found db
        hosts=`find_users_hosts $USER`
        for HOST in $hosts ; do
            mysql -e "grant all on $DB.* to '$USER'@'$HOST'; "
        done

        #assign database,dbuser to cpanel account
        /usr/local/cpanel/bin/dbmaptool $CPUSER --type mysql --dbs $DB --dbusers $USER
    else
        warn "Detected root user! skipping!"
    fi

}

function please_for_the_love_of_dollarsign_deity() {
    threaten "remove $passfile when you are done"
}

function parse_conf() {
    local file="$1"
    local cpuser="$2"
#for file in $(cat $conffiles); do
    Count=$((Count+1))
        if (($Verbose!=0)) ; then  echo checking $file ; fi
        case $(basename $file) in
                wp-config.php) # wordpress
                    DBUSER=$(grep DB_USER $file | cut -d\' -f4)
                    DBPASS=$(grep DB_PASSWORD $file | cut -d\' -f4)
                    DB=$(grep DB_NAME $file | cut -d\' -f4)
                ;;
                configuration.php) # joomla
                    if grep -q JConfig $file; then #Joomla 1.5+
                        DBUSER=$(grep '$user' $file | cut -d\' -f2)
                        DBPASS=$(grep '$password' $file | cut -d\' -f2)
                        DB=$(grep '$db = ' $file | cut -d\' -f2)
                    elif grep -q mosConfig_user $file; then  #Joomla 1.0
                        DBUSER=$(grep '^\$mosConfig_user =' $file | cut -d\' -f2)
                        DBPASS=$(grep '^\$mosConfig_password =' $file | cut -d\' -f2)
                        DB=$(grep '^\$mosConfig_db =' $file | cut -d\' -f2)
                    fi
                ;;
            local.xml)  # magento
                    if grep -q CDATA $file; then #Older Magento versions
                    DBUSER=$(grep username $file | cut -f3 -d"[" | cut -f1 -d"]")
                    DBPASS=$(grep password $file | cut -f3 -d"[" | cut -f1 -d"]")
                    DB=$(grep dbname $file | cut -f3 -d"[" | cut -f1 -d"]")
                    else #Newer Magento versions
                DBUSER=$(grep username $file | cut -f3 -d"<" | cut -f1 -d">")
                        DBPASS=$(grep password $file | cut -f3 -d"<" | cut -f1 -d">")
                        DB=$(grep dbname $file | cut -f3 -d"<" | cut -f1 -d">")
                    fi
            ;;
            systemComponent.php) #unknown
                    DBUSER=$(grep dbusername $file |cut -f4 -d"'"|tail -n 1)
                    DBPASS=$(grep dbpassword $file |cut -f4 -d"'"|tail -n 1)
                    DB=$(grep dbname $file |cut -f4 -d"'"|tail -n 1)
            ;;
            settings.php) #Drupal
                    if grep -q db_url $file;then #Check for drupal < version 6
                         #Get info for version < 6
                        DBUSER=$(cat $file | grep "^\$db_url =" | cut -f2 -d":" | sed "s/.*\/\///g")
                        DBPASS=$(cat $file | grep "^\$db_url =" | cut -f3 -d ":" | sed "s/.[^@]*$//")
                        DB=$(cat $file| grep "^\$db_url =" | cut -f4 -d"/" | rev | cut -c3- | rev)
                    else
                    #Get infor for version 6+
                        DBUSER=$(grep "'username' =>" $file |cut -f4 -d"'"|tail -n 1)
                        DBPASS=$(grep "'password' =>" $file |cut -f4 -d"'"|tail -n 1)
                        DB=$(grep "'database' =>" $file |cut -f4 -d"'"|tail -n 1)
                    fi

            ;;
            configure.php) #osCommerce
                DBUSER=$(grep DB_SERVER_USERNAME $file |cut -f4 -d"'")
                DBPASS=$(grep DB_SERVER_PASSWORD $file |cut -f4 -d"'")
                DB=$(grep DB_DATABASE $file |cut -f4 -d"'")
            ;;
        esac
        write_creds "$DBUSER" "$DBPASS" "$DB" "$cpuser" "$file"
}


function confsearch() {
    > $passfile
    > $conffilelocations
    Count=0
    info "searching for configurations"
    for user in $userlist; do
        info "Searching for $user..."
        conffiles=`find /home/$user -type f $findparam `
        conffileCount=0
        for file in $conffiles ; do
            info "parsing $file for user $user ...."
            conffileCount=$((conffileCount+1))
            parse_conf "$file" "$user"
        done
        Count=$((Count+1))
        echo $conffiles >> $conffilelocations
        info "Parsed $conffileCount files for $user."
    done
    info "done. $Count configs processed."
}

mysql_fix() {
    if [ -f $passfile ]; then
        cat $passfile | while read USER PASS DB CPUSER FILE; do
            mysql_perms "$USER" "$PASS" "$DB" "$CPUSER" "$FILE";
        done
        mysql -e "flush privileges ;"
    else
        warn "$passfile does not exist"
        exit 1
    fi
}

#main##

explode_if_shared

while (( "$#" )) ; do
    case $1 in
        -userlist)
            echo userlist
            if (("$#" < 2)) ; then
                echo "please specify the userlist if ... specifying a userlist..."
                exit 1
            fi
            #checking argument after -userlist...
            shift

            tmp_userlist="$1"
            #specify 'all' for all users
            if [[ "$1" == "all" ]]; then
                echo "Running for all users!"
                userlist=$(/bin/ls -A /var/cpanel/users)
            #check for empty file
            elif [ -e "$1" ]; then
                userlist=$(cat $1)
                echo "Detected userlist given as a file: $1"
            else
                userlist="$1"
                echo "Detected cpanel users from command line '$userlist'"
            fi
        ;;

        -v)
            Verbose=1
        ;;

        -help)
            print_help
            exit 1
        ;;
        -fixmysql)
            info "Mysql fixing selected"
            fixmysql=1
        ;;
        -justfix)
            info "just fixing..."
            mysql_fix
            please_for_the_love_of_dollarsign_deity
            exit
        ;;
        *)
            echo "unsported arg. $1"
            print_help
            exit
        ;;
    esac
    shift
done

if [ -z "$userlist" ]; then
    print_help
    exit
    #userlist=$(/bin/ls -A /var/cpanel/users)
fi

trap please_for_the_love_of_dollarsign_deity EXIT

confsearch

info "Info found:"
cat $passfile

#separate paramater for updating mysql privs
if [[ "$fixmysql" ]]; then
    mysql_fix
fi



echo "bye!"
