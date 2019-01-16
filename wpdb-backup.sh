#!/bin/bash

echo 'Starting Backup'

WPDBHOST=`cat wp-config.php | grep DB_HOST | cut -d \' -f 4`;
WPDBNAME=`cat wp-config.php | grep DB_NAME | cut -d \' -f 4`;
WPDBUSER=`cat wp-config.php | grep DB_USER | cut -d \' -f 4`;
WPDBPASS=`cat wp-config.php | grep DB_PASSWORD | cut -d \' -f 4`;

echo 'Grabbing Database'

FILE=mysql-$WPDBNAME.sql.gz;        # Set the backup filename

#echo "mysqldump -q -u $WPDBUSER -h $WPDBHOST -p$WPDBPASS $WPDBNAME | gzip -9 > $FILE";
mysqldump -q -u $WPDBUSER -h $WPDBHOST -p$WPDBPASS $WPDBNAME | gzip -9 > dbbackup.sql.gz



mysqldump -q -u cfportal_wp710 -h 10.223.192.181 -p-ES5]17P39 cfc_apps | gzip -9 > cfc_apps.sql.gz