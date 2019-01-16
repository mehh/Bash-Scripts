#!/bin/bash
#----------------------------------------------------------------------------------------------#
# db-migrate.sh v0.1 (#0 2016-01-05)                                                           #
#                                                                                              #
# # This script will handle all of the database migration requirements for our remote db       #
############################## Modification Log ##############################                 #
# Date          Who             Version         Description
# 20160105      kchase/nwpickre 0.1             Initial Release



if [ $# -eq 0 ]
  then
    echo "You MUST supply cPanel account"
    exit;
fi


# Destination Server
v_rsshusr="root"
v_rsshhost="67.227.199.118"
v_rsshport="22"
v_rsshpass="vS@Hv3JmRa" 

v_remoteServer="%"

# sql file to hold grants and db info locally
_tmp="/tmp/db-output.mysql.$$.sql"
v_MagentoSQL="db_magento.sql"
v_WordPressSQL="db_wordpress.sql"

v_AccountName=$1
v_SITEDIR="/home/${v_AccountName}"


# xml_value path/to/file node_key
function xml_value(){
    grep "<$2>.*<.$2>" $1 | sed -e "s/<\!\[CDATA\[//" | sed -e "s/\]\]>//" | sed -e "s/^.*<$2/<$2/" | cut -f2 -d">"| cut -f1 -d"<"
}



echo	"+		Checking if Magento exists in user directory"
v_MagentoDir=`find ${v_SITEDIR} -name Mage.php`
v_hasMagento=$?
echo	"+		Checking if WordPress exists in user directory"
v_WordpressDir=`find ${v_SITEDIR} -name wp-config.php`
v_hasWP=$?

if [[ x"${v_hasMagento}" == x"0" ]];then
	echo	"+		Magento Found"
	v_MagentoDir=`echo "${v_MagentoDir}" | sed 's^app/Mage.php^^'`

	#	Grab variables from app/etc/local.xml
		v_Magento_DB_HOST=$(xml_value ${v_MagentoDir}app/etc/local.xml host)
		v_Magento_DB_USER=$(xml_value ${v_MagentoDir}app/etc/local.xml username)
		v_Magento_DB_PASS=$(xml_value ${v_MagentoDir}app/etc/local.xml password)
		v_Magento_DB_NAME=$(xml_value ${v_MagentoDir}app/etc/local.xml dbname)

		cat /dev/null > ${v_MagentoSQL}
		echo "CREATE DATABASE ${v_Magento_DB_NAME};"$'\r' >> ${v_MagentoSQL}
		echo "CREATE USER '${v_Magento_DB_USER}'@'${v_Magento_DB_HOST}' IDENTIFIED BY '${v_Magento_DB_PASS}';"$'\r' >> ${v_MagentoSQL}
		echo "GRANT ALL PRIVILEGES ON ${v_Magento_DB_NAME}.* TO '${v_Magento_DB_USER}'@'${v_Magento_DB_HOST}';"$'\r' >> ${v_MagentoSQL}
		echo "GRANT ALL PRIVILEGES ON ${v_Magento_DB_NAME}.* TO '${v_Magento_DB_USER}'@'${v_remoteServer}';"$'\r' >> ${v_MagentoSQL}

		echo "GRANT ALL PRIVILEGES ON ${v_Magento_DB_NAME}.* TO '${v_Magento_DB_USER}'@'10.30.4.100';"$'\r' >> ${v_MagentoSQL}
		echo "GRANT ALL PRIVILEGES ON ${v_Magento_DB_NAME}.* TO '${v_Magento_DB_USER}'@'10.36.149.195';"$'\r' >> ${v_MagentoSQL}
		echo "GRANT ALL PRIVILEGES ON ${v_Magento_DB_NAME}.* TO '${v_Magento_DB_USER}'@'10.39.136.243';"$'\r' >> ${v_MagentoSQL}
		echo "GRANT ALL PRIVILEGES ON ${v_Magento_DB_NAME}.* TO '${v_Magento_DB_USER}'@'10.39.136.242';"$'\r' >> ${v_MagentoSQL}
		echo "GRANT ALL PRIVILEGES ON ${v_Magento_DB_NAME}.* TO '${v_Magento_DB_USER}'@'127.0.0.1';"$'\r' >> ${v_MagentoSQL}
		echo "GRANT ALL PRIVILEGES ON ${v_Magento_DB_NAME}.* TO '${v_Magento_DB_USER}'@'67.227.199.114';"$'\r' >> ${v_MagentoSQL}
		echo "GRANT ALL PRIVILEGES ON ${v_Magento_DB_NAME}.* TO '${v_Magento_DB_USER}'@'68.225.19.50';"$'\r' >> ${v_MagentoSQL}
		echo "GRANT ALL PRIVILEGES ON ${v_Magento_DB_NAME}.* TO '${v_Magento_DB_USER}'@'68.5.127.235';"$'\r' >> ${v_MagentoSQL}

		echo "SHOW GRANTS FOR ${v_Magento_DB_USER}@${v_Magento_DB_HOST};"$'\r' >> ${v_MagentoSQL}
		echo "FLUSH PRIVILEGES;"$'\r' >> ${v_MagentoSQL}

		scp ${v_MagentoSQL} ${v_rsshusr}@${v_rsshhost}:
		ssh ${v_rsshusr}@${v_rsshhost} "mysql -u ${v_rsshusr} -p${v_rsshpass} < ${v_MagentoSQL}"

		mysqldump -u "${v_Magento_DB_USER}" -p"${v_Magento_DB_PASS}" -h "${v_Magento_DB_HOST}" "${v_Magento_DB_NAME}" | ssh ${v_rsshusr}@${v_rsshhost} mysql -u "${v_Magento_DB_USER}" -p"${v_Magento_DB_PASS}" -h "${v_Magento_DB_HOST}" "${v_Magento_DB_NAME}"

		ssh ${v_rsshusr}@${v_rsshhost} "rm -f ${v_MagentoSQL}"	
fi	

if [[ x"${v_hasWP}" == x"0" ]];then
	echo	"+		WordPress Found"
    #    Grab variables from wp-config
        v_WP_DB_HOST=`cat ${v_WordpressDir}|grep DB_HOST|grep -Po "(?<=')[^']+(?=')"|tail -n 1`
        v_WP_DB_USER=`cat ${v_WordpressDir}|grep DB_USER|grep -Po "(?<=')[^']+(?=')"|tail -n 1`
        v_WP_DB_PASS=`cat ${v_WordpressDir}|grep DB_PASSWORD|grep -Po "(?<=')[^']+(?=')"|tail -n 1`
        v_WP_DB_NAME=`cat ${v_WordpressDir}|grep DB_NAME|grep -Po "(?<=')[^']+(?=')"|tail -n 1`

        cat /dev/null > ${v_WordPressSQL}
        echo "CREATE DATABASE ${v_WP_DB_NAME};"$'\r' >> ${v_WordPressSQL}
        echo "CREATE USER '${v_WP_DB_USER}'@'${v_WP_DB_HOST}' IDENTIFIED BY '${v_WP_DB_PASS}';"$'\r' >> ${v_WordPressSQL}
        echo "GRANT ALL PRIVILEGES ON ${v_WP_DB_NAME}.* TO '${v_WP_DB_USER}'@'${v_WP_DB_HOST}';"$'\r' >> ${v_WordPressSQL}
        echo "GRANT ALL PRIVILEGES ON ${v_WP_DB_NAME}.* TO '${v_WP_DB_USER}'@'${v_remoteServer}';"$'\r' >> ${v_WordPressSQL}
       
       echo "GRANT ALL PRIVILEGES ON ${v_WP_DB_NAME}.* TO '${v_WP_DB_USER}'@'10.30.4.100';"$'\r' >> ${v_WordPressSQL}
       echo "GRANT ALL PRIVILEGES ON ${v_WP_DB_NAME}.* TO '${v_WP_DB_USER}'@'10.36.149.195';"$'\r' >> ${v_WordPressSQL}
       echo "GRANT ALL PRIVILEGES ON ${v_WP_DB_NAME}.* TO '${v_WP_DB_USER}'@'10.39.136.243';"$'\r' >> ${v_WordPressSQL}
       echo "GRANT ALL PRIVILEGES ON ${v_WP_DB_NAME}.* TO '${v_WP_DB_USER}'@'10.39.136.242';"$'\r' >> ${v_WordPressSQL}
       echo "GRANT ALL PRIVILEGES ON ${v_WP_DB_NAME}.* TO '${v_WP_DB_USER}'@'127.0.0.1';"$'\r' >> ${v_WordPressSQL}
       echo "GRANT ALL PRIVILEGES ON ${v_WP_DB_NAME}.* TO '${v_WP_DB_USER}'@'67.227.199.114';"$'\r' >> ${v_WordPressSQL}
       echo "GRANT ALL PRIVILEGES ON ${v_WP_DB_NAME}.* TO '${v_WP_DB_USER}'@'68.225.19.50';"$'\r' >> ${v_WordPressSQL}
       echo "GRANT ALL PRIVILEGES ON ${v_WP_DB_NAME}.* TO '${v_WP_DB_USER}'@'68.5.127.235';"$'\r' >> ${v_WordPressSQL}

        echo "SHOW GRANTS FOR ${v_WP_DB_USER}@${v_WP_DB_HOST};"$'\r' >> ${v_WordPressSQL}
        echo "FLUSH PRIVILEGES;"$'\r' >> ${v_WordPressSQL}

        scp ${v_WordPressSQL} ${v_rsshusr}@${v_rsshhost}:
        ssh ${v_rsshusr}@${v_rsshhost} "mysql -u ${v_rsshusr} -p${v_rsshpass} < ${v_WordPressSQL}"

        mysqldump -u "${v_WP_DB_USER}" -p"${v_WP_DB_PASS}" -h "${v_WP_DB_HOST}" "${v_WP_DB_NAME}" | ssh ${v_rsshusr}@${v_rsshhost} mysql  -u "${v_WP_DB_USER}" -p"${v_WP_DB_PASS}" -h "${v_WP_DB_HOST}" "${v_WP_DB_NAME}"

        ssh ${v_rsshusr}@${v_rsshhost} "rm -f ${v_WordPressSQL}"	
fi
