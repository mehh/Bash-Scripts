#!/bin/bash


while read p; do
# echo "/backup/cpbackup/daily/${p}.tar.gz";
	rsync -avz root@prod:/backups/cpbackup/daily/${p}.tar.gz "/Volumes/CloudLocal/Server Backups/20150508/" &



done < rsync.txt