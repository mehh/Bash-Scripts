#!/bin/sh
#----------------------------------------------------------------------------------------------#
# db-backup.sh v0.1 (#0 2016-08-05)                                                           #
#                                                                                              #
# Script to be used as part of automated mysql backup process
############################## Modification Log ##############################                 #
# Date          Who             Version         Description
# 20160805      kchase			 0.1             Initial Release

### System Variables
v_NOW=`date +%Y-%m-%d`
v_KEEPDAYS=5
v_envFile=/vagrant/.env

### MySQL Setup ###
v_WPDBHOST=`cat /vagrant/.env | grep DB_HOST | cut -d \= -f 2`;
v_WPDBNAME=`cat /vagrant/.env | grep DB_NAME | cut -d \= -f 2`;
v_WPDBUSER=`cat /vagrant/.env | grep DB_USER | cut -d \= -f 2`;
v_WPDBPASS=`cat /vagrant/.env | grep DB_PASSWORD | cut -d \= -f 2`;


v_FILE=/vagrant/backups/mysql-${v_WPDBNAME}.${v_NOW}.sql.gz        # Set the backup filename

###	Start MySQL Backup
    mysqldump -q -u ${v_WPDBUSER} -h ${v_WPDBHOST} -p${v_WPDBPASS} ${v_WPDBNAME} | gzip -9 > ${v_FILE}

### Cleanup
	#find /vagrant/backups/mysql*.sql.gz -type f -daystart -mtime +${v_KEEPDAYS} -exec rm {} \\;
