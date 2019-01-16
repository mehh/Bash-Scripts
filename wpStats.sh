#!/bin/bash

	#	Cron
		#	15 2 * * * cd /home/username/public_html; /usr/local/bin/php /home/username/wp-cli.phar export >/dev/null 2>&1

	#	Search & Replace
		#	
			#
	#	DB
		#	Save DB
			# wp db dump
		#	Import DB
			# wp db import filename.sql
		#	Optimize DB
			# wp db optimize
		#	Repair DB
			# wp db repair




	v_wpDir="${HOME}/public_html/"

	#	Core
		#	Get WP Version
			v_wpVersion=`wp --path=${v_wpDir} core version`
		#	Determine if blog is hidden from google
			wp option get blog_public
		#	Determine if using gzip compresision
			wp option get gzipcompression
		#	Get Admin Email
			v_adminEmail=`wp --path=${v_wpDir} option get gzipcompression`
	#	Plugins
		#	Get plugin status
			v_pluginStatus=`wp --path=${v_wpDir} plugin status`
		#	Get Plugin List
			v_pluginList=`wp --path=${v_wpDir} plugin list`

	#	Themes
		#	Get theme status
			v_themeStatus=`wp --path=${v_wpDir} theme status`
		#	Get theme list
			v_themeList=`wp --path=${v_wpDir} theme list`

	#	Posts
		#	Get posts list
			v_postList=`wp --path="${v_wpDir}" post list`

	#	Comments
		#	Get comments status
			v_commentStatus=`wp --path="${v_wpDir}" comment count all`
		#	Get comments list
			v_commentList=`wp --path="${v_wpDir}" comment list`
	#	Users
		#	Get user list
			v_userList=`wp --path="${v_wpDir}" user list`

	echo "WP Version: "${v_wpVersion}

	echo -e "WP plugin status: "
	wp --path=${v_wpDir} plugin list
	echo ""
	echo -e "WP theme status: "
	wp --path=${v_wpDir} theme status
	echo ""
	echo -e "WP post list: "
	wp --path="${v_wpDir}" post list
	echo ""
	echo -e "WP comment status: "
	wp --path="${v_wpDir}" comment count all
	echo ""
	echo -e "WP user list: "
	wp --path="${v_wpDir}" user list

