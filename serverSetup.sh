#!/bin/bash
#	Script by Kris Chase
#	https://krischase.com
#
# 	A basic set of commands which are valuable to run on a new WHM / cPanel server


####################################
#	Install New Repo/Packages	   #
####################################
	wget http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
	rpm -ivh epel-release-6-8.noarch.rpm
	yum -y update
	yum --enablerepo=epel update
	yum --enablerepo=epel upgrade
	yum -y install htop figlet jpegoptim optipng s3cmd screen perl wget

####################################
#	Install n98			   #
####################################
	wget http://files.magerun.net/n98-magerun-latest.phar -O n98-magerun.phar
	chmod +x ./n98-magerun.phar
	mv n98-magerun.phar n98
	cp ./n98 /usr/local/bin/

####################################
#	Install wp-cli			   #
####################################
	curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
	chmod +x wp-cli.phar
	sudo mv wp-cli.phar /usr/local/bin/wp

####################################
#	Install FireWall			   #
####################################
	wget http://www.configserver.com/free/csf.tgz
	tar -xzf csf.tgz
	cd csf
	sh install.sh
	service csf restart



####################################
#	Compress Images				   #
####################################
find . -iname *.jpg | xargs jpegoptim --max=80 --all-progressive --strip-all --strip-com --strip-exif --strip-iptc --strip-icc &
find . -iname *.png -print0 |xargs -0 optipng -o7 &

####################################
#	Transfer Firewall			   #
####################################
cd /etc/csf/
scp csfbackup.tgz


scp /var/cpanel/easy/apache/profile/custom/myprofile.yaml !root@$IP:/var/cpanel/easy/apache/profile/custom/myprofile.yaml