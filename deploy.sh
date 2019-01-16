#!/bin/bash

	#	Notes
		#	Need to talk to jonathan about deploying SSH keys and where these scripts will be deployed from initially (windows, linux, etc).
		#	Need to install git on the servers where the site will be deployed


	#	This script will be used to deploy the cf.com website.


		#	Steps
			#	Use grand SSH script to deploy This
			#	This script will need to determine if it's connecting to the web server or DB Server
			#	cd to web root / wordpress  (theme?) perhaps we should put the entire site on the repo in this case
			#	git pull repo


	#########	Dev Notes	#########
		#	Determine if user account exists in system
			#	`whoami`

		#	If site exists, grab the post ID
			#	Else, insert a new row into wp_posts and then grab post ID

		#	Determine if script is running on a production or development server

			#####		#####

	#########	/Dev Notes	#########

	######	Variables	#####
		#	Date
			export v_CurrentDateTime=$( date +"%Y-%m-%d %H:%M:%S" )
		#gtmetrix API info
			export g_GTMETRIX_USER=''
			export g_GTMETRIX_KEY=''