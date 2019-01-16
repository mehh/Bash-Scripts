#!/bin/bash

if [ $# -eq 0 ]
  then
    echo "You MUST supply account to search for"
    exit;
fi

    v_accountSearch=$1

    #find all files named wp-config.php in our home directory
 
    # directoriesToCheck=('/home/newcf/public_html/*/wp-config.php' 'ls /home/newcf/public_html/wp-config.php')
    directoriesToCheck=('/home/*/public_html/*/wp-config.php' 'ls /home/*/public_html/wp-config.php')
    #find /home/ -name wp-config.php | while read SITEDIR; do
    #locate wp-config.php | while read SITEDIR; do
    for Directory in "${directoriesToCheck[@]}"; do
        for SITEDIR in `ls ${Directory}`; do
 
            #       Grab the account name
                v_Account=`echo ${SITEDIR} | awk -F'/' '{ print $3 }'`
 
            #    Make sure our wp-config is on public_html and not softaculous or something
            if echo ${SITEDIR} | grep --quiet public_html ; then
 
                #    Grab variables from wp-config
                    v_DBHost=`cat ${SITEDIR}|grep DB_HOST|grep -Po "(?<=')[^']+(?=')"|tail -n 1`
                    v_DBUser=`cat ${SITEDIR}|grep DB_USER|grep -Po "(?<=')[^']+(?=')"|tail -n 1`
                    v_DBPass=`cat ${SITEDIR}|grep DB_PASSWORD|grep -Po "(?<=')[^']+(?=')"|tail -n 1`
                    v_DBName=`cat ${SITEDIR}|grep DB_NAME|grep -Po "(?<=')[^']+(?=')"|tail -n 1`
 
                #    Find user
                    v_wpUser=$(echo "SELECT user_login FROM wp_users WHERE user_login LIKE \"%${v_accountSearch}%\"" | mysql -s -N -D ${v_DBName} -h ${v_DBHost} -u ${v_DBUser} -p${v_DBPass})
 
                if echo ${v_wpUser} | grep --quiet gsadmin ; then
                    for username in `echo ${v_wpUser}`; do
                        #    Generate new password
                        #v_newPass=$(</dev/urandom tr -dc '12345!@#%qwertQWERTasdfgASDFGzxcvbZXCVB' | head -c16; echo "")
 
                        #    Echo some stuff to the screen
                            echo "${v_Account},${username}"
 
                            # if [[ x"${v_Account}" == x"sterinof" ]]; then
                                #    Update password
                         #           $(echo "UPDATE wp_users SET user_pass = MD5(\"${v_newPass}\") WHERE user_login=\"${username}\";" | mysql -D ${v_DBName} -h ${v_DBHost} -u ${v_DBUser} -p${v_DBPass})
                                # fi
                        echo "${SITEDIR},${v_Account},${username},${v_newPass},SUCCESS" >> wPPasswords.txt
                    done
                else
                    echo "${SITEDIR},${v_Account},,,couldn't find ${v_accountSearch} account" >> wPPasswords.txt
                fi
 
                echo "++++++++++++++++++++";
            else
                echo "${SITEDIR},${v_Account},,,Non public_html" >> wPPasswords.txt
            fi # end fi for grepping public_html
        done
    done