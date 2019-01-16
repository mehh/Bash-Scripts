#!/bin/bash
# Copyright (c) 2005 nixCraft project <http://cyberciti.biz/fb/>
# This script is licensed under GNU GPL version 2.0 or above
# Author Vivek Gite <vivek@nixcraft.com>
# ------------------------------------------------------------
# SETME First - local mysql user/pass
_lusr="drjla_mag2"
_lpass="0N^%?X^BSNdE"
_lhost="localhost"
 
# SETME First - remote mysql user/pass
_rusr="root"
_rpass="vS@Hv3JmRa"
_rhost="localhost"
 
# SETME First - remote mysql ssh info 
# Make sure ssh keys are set
_rsshusr="root"
_rsshhost="67.227.199.118"
 
# sql file to hold grants and db info locally
_tmp="/tmp/output.mysql.$$.sql"
 
#### No editing below #####
 
# Input data
_db="$1"
_user="$2"
 
# Die if no input given
[ $# -eq 0 ] && { echo "Usage: $0 MySQLDatabaseName MySQLUserName"; exit 1; }
 
# Make sure you can connect to local db server
mysqladmin -u "$_lusr" -p"$_lpass" -h "$_lhost"  ping &>/dev/null || { echo "Error: Mysql server is not online or set correct values for _lusr, _lpass, and _lhost"; exit 2; }
 
# Make sure database exists
mysql -u "$_lusr" -p"$_lpass" -h "$_lhost" -N -B  -e'show databases;' | grep -q "^${_db}$" ||  { echo "Error: Database $_db not found."; exit 3; }
 
##### Step 1: Okay build .sql file with db and users, password info ####
echo "*** Getting info about $_db..."
echo "create database IF NOT EXISTS $_db; " > "$_tmp"
 
# Build mysql query to grab all privs and user@host combo for given db_username
mysql -u "$_lusr" -p"$_lpass" -h "$_lhost" -B -N \
-e "SELECT DISTINCT CONCAT('SHOW GRANTS FOR ''',user,'''@''',host,''';') AS query FROM user" \
| mysql  -u "$_lusr" -p"$_lpass" -h "$_lhost" \
| grep  "$_user" \
|  sed 's/Grants for .*/#### &/' >> "$_tmp"
 
##### Step 2: send .sql file to remote server ####
echo "*** Creating $_db on ${_rsshhost}..."
scp "$_tmp" ${_rsshusr}@${_rsshhost}:/tmp/
 
#### Step 3: Create db and load users into remote db server ####
ssh ${_rsshusr}@${_rsshhost} mysql -u "$_rusr" -p"$_rpass" -h "$_rhost" < "$_tmp"
 
#### Step 4: Send mysql database and all data ####
echo "*** Exporting $_db from $HOSTNAME to ${_rsshhost}..."
mysqldump -u "$_lusr" -p"$_lpass" -h "$_lhost" "$_db" | ssh ${_rsshusr}@${_rsshhost} mysql  -u "$_rusr" -p"$_rpass" -h "$_rhost" "$_db"
 
#rm -f "$_tmp"