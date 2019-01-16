#!/bin/bash


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
	######	/Variables	#####

	######	ACF	FIELD KEYS	######
			export development_ip_field_key='field_535c2f896686d'
			export development_ip_field_name='development_ip'

			export development_url_field_key='field_535c2f4a6686c'
			export development_url_field_name='development_url'

			export development_server_field_key='field_535c308c6686f'
			export development_server_field_name='development_server'

			export development_username_field_key='field_535c32b119c2f'
			export development_username_field_name='development_username'

			export development_password_field_key='field_535c32c719c30'
			export development_password_field_name='development_password'


			export production_ip_field_key='field_5365988ca5a79'
			export production_ip_field_name='production_ip'

			export production_url_field_key='field_536598a4a5a7a'
			export production_url_field_name='production_url'

			export production_server_field_key='field_536598d4a5a7c'
			export production_server_field_name='production_server'

			export production_username_field_key='field_536598f0a5a7d'
			export production_username_field_name='production_username'

			export production_password_field_key='field_536598fda5a7e'
			export production_password_field_name='production_password'

	######	/ACF	FIELD KEYS	######






	######	Functions ######

		function getCurrentDateTime ()
		{
			export v_CurrentDateTime=$( date +"%Y-%m-%d %H:%M:%S" )
		}

		function getWpAdmin ()
		{
			export v_WPAdmin=$( wp user list --role=administrator --format=csv|grep gsadmin| awk -F',' '{ print $2 }' )
		}

		function getCurrentServer ()
		{

			v_CurrentHostname=`hostname`

			if [[ x"${v_CurrentHostname}" == x"host5.whiteinkstudio.com" ]]; then
				v_CurrentHost='Production'
			elif [[ x"${v_CurrentHostname}" == x"host3.whiteinkstudio.com" ]]; then
				v_CurrentHost='Development'
			else
				v_CurrentHost='Other'
			fi

		#	URL	#
			if [[ x"${v_CurrentHost}" == x"Production" ]]; then
				v_CSServer='host5.whiteink'
			elif [[ x"${v_CurrentHost}" == x"Development" ]];then
				v_CSServer='host3.whiteink'
			else
				v_CSServer='Other'
			fi

			return 0;
		}

		function getCurrentSitePostID ()
		{
			v_SiteAccount=${1}

			#	Try to grab current account post ID
			v_CS_ID=$(echo "SELECT ID FROM wp_posts WHERE post_title = \"${v_SiteAccount}\" AND post_status=\"publish\"" | mysql -s -N -D ${v_GC_DBName} -h ${v_GC_DBHost} -u ${v_GC_DBUser} -p${v_GC_DBPass})

			#	Check if PostID Existed or not
			if [[ x"${v_CS_ID}" == x"" ]]; then
				#	Let's create the post in GigaCode
				echo "Creating new post..."

				getCurrentDateTime
				#	Initialize variables
				v_CS_post_author='4'
				v_CS_post_date=${v_CurrentDateTime}
				v_CS_post_date_gmt=${v_CurrentDateTime}
				v_CS_post_content=''
				v_CS_post_title=${v_SiteAccount}
				v_CS_post_excerpt=''
				v_CS_post_status='publish'
				v_CS_post_comment_status='closed'
				v_CS_post_ping_status='closed'
				v_CS_post_password=''
				v_CS_post_name=${v_SiteAccount}
				v_CS_post_to_ping=''
				v_CS_post_pinged=''
				v_CS_post_modified=${v_CurrentDateTime}
				v_CS_post_modified_gmt=${v_CurrentDateTime}
				v_CS_post_content_filtered=''
				v_CS_post_parent='0'
				v_CS_post_guid=''
				v_CS_post_menu_order='0'
				v_CS_post_type='site'
				v_CS_post_mime_type=''
				v_CS_post_comment_count='0'


				#	Set the insert string
				v_insertString="INSERT INTO wp_posts (post_author,post_date,post_date_gmt,post_content,post_title,post_excerpt,post_status,comment_status,ping_status,post_password,post_name,to_ping,pinged,post_modified,post_modified_gmt,post_content_filtered,post_parent,guid,menu_order,post_type,post_mime_type,comment_count) values (
					\"${v_CS_post_author}\",\"${v_CS_post_date}\",\"${v_CS_post_date_gmt}\",\"${v_CS_post_content}\",\"${v_CS_post_title}\",\"${v_CS_post_excerpt}\",\"${v_CS_post_status}\",\"${v_CS_comment_status}\",\"${v_CS_ping_status}\",\"${v_CS_post_password}\",\"${v_CS_post_name}\",\"${v_CS_to_ping}\",\"${v_CS_pinged}\",\"${v_CS_post_modified}\",\"${v_CS_post_modified_gmt}\",\"${v_CS_post_content_filtered}\",\"${v_CS_post_parent}\",\"${v_CS_guid}\",\"${v_CS_menu_order}\",\"${v_CS_post_type}\",\"${v_CS_post_mime_type}\",\"${v_CS_comment_count}\");"

					#	Do the insert
					v_CS_ID=$(echo ${v_insertString} | mysql -s -N -D ${v_GC_DBName} -h ${v_GC_DBHost} -u ${v_GC_DBUser} -p${v_GC_DBPass})

				#	Set string for grabbing post ID
				v_SelectString="SELECT ID FROM wp_posts WHERE post_title = \"${v_SiteAccount}\" AND post_status=\"publish\""

					#	Do the select
					v_CS_ID=$(echo ${v_SelectString} | mysql -s -N -D ${v_GC_DBName} -h ${v_GC_DBHost} -u ${v_GC_DBUser} -p${v_GC_DBPass})

					v_insertString=''
					v_SelectString=''
			fi

			return $?
		}

		function deleteWpData ()
		{
			#	Setup string for deleting old plugin information
				v_DeleteString="DELETE FROM wp_postmeta WHERE post_id=\"${v_CS_ID}\" AND meta_key LIKE \"installed_on_site\""
				echo ${v_DeleteString}| mysql -s -N -D ${v_GC_DBName} -h ${v_GC_DBHost} -u ${v_GC_DBUser} -p${v_GC_DBPass}

				return $?
		}

		function insertWPMeta()
		{

				development_ip=v$( echo ${v_CSURL} | sed 's/http\:\/\///'| dig +short ${v_CSURL} )
				development_url=${v_CSURL}
				development_server=${v_CSServer}
				development_username=${v_WPAdmin}

				metaToInsert=( 'development_ip' 'development_url' 'development_server' 'development_username' )


				for meta in ${metaToInsert}; do

					echo "meta: ${meta}"
					echo "metaID: ${v_metaKeyID}"
					echo "metaKeyName: ${v_metaKeyName}"
					echo "metaValue: ${v_metaValue}"


					#	Insert version meta line
					v_urlIPLine="INSERT INTO wp_postmeta (post_id,meta_key,meta_value) values (\"${v_CS_ID}\",\"${v_metaKeyName}\",\"${meta}\")"
					echo ${v_urlIPLine}| mysql -s -N -D ${v_GC_DBName} -h ${v_GC_DBHost} -u ${v_GC_DBUser} -p${v_GC_DBPass}

					#	Insert version ACF line
					v_urlIPLine="INSERT INTO wp_postmeta (post_id,meta_key,meta_value) values (\"${v_CS_ID}\",\""_"${v_metaKeyName}\",\"${v_metaKeyID}\")"
					echo ${v_urlIPLine}| mysql -s -N -D ${v_GC_DBName} -h ${v_GC_DBHost} -u ${v_GC_DBUser} -p${v_GC_DBPass}

				done




					v_CSServerMetaName="url/ip_0_server"
					v_CSServerKey='field_534d7b4e5d3bb'

					#	Insert version meta line
					v_insertVersionMeta="INSERT INTO wp_postmeta (post_id,meta_key,meta_value) values (\"${v_CS_ID}\",\"${v_CSServerMetaName}\",\"${v_CSServer}\")"
					echo ${v_insertVersionMeta}| mysql -s -N -D ${v_GC_DBName} -h ${v_GC_DBHost} -u ${v_GC_DBUser} -p${v_GC_DBPass}

					#	Insert version ACF line
					v_insertVersionACF="INSERT INTO wp_postmeta (post_id,meta_key,meta_value) values (\"${v_CS_ID}\",\""_"${v_CSServerMetaName}\",\"${v_CSServerKey}\")"
					echo ${v_insertVersionACF}| mysql -s -N -D ${v_GC_DBName} -h ${v_GC_DBHost} -u ${v_GC_DBUser} -p${v_GC_DBPass}
				#	/URL	#

				#	IP Address	#





		}

		function insertPlugins()
		{
			#	Import plugin information

			#v_CS_Plugins=$(wp --path=${v_fullWPPath} plugin list --format=csv)


			currentPluginNum=0;
			wp --path=${v_fullWPPath} plugin list --format=csv | while read v_PluginLine; do
				#echo "${v_PluginLine}"

				v_PluginName=$(echo ${v_PluginLine} | awk -F',' '{print $1}')
				v_PluginStatus=$(echo ${v_PluginLine} | awk -F',' '{print $2}')
				v_PluginUpdate=$(echo ${v_PluginLine} | awk -F',' '{print $3}')
				v_PluginVersion=$(echo ${v_PluginLine} | awk -F',' '{print $4}')

					if [[ x"${v_PluginName}" == x"name" && x"${v_PluginStatus}" == x"status" ]]; then
						continue
					fi

				#	NAME	#
					v_NameMetaKeyName="url/ip_0_installed_on_site_0_plugins/extensions_${currentPluginNum}_name"
					v_NameMetaKeyID='field_5347d7b0a5d3b9'

					#	Insert version meta line
					v_insertNameMeta="INSERT INTO wp_postmeta (post_id,meta_key,meta_value) values (\"${v_CS_ID}\",\"${v_NameMetaKeyName}\",\"${v_PluginName}\")"
					echo ${v_insertNameMeta} | mysql -s -N -D ${v_GC_DBName} -h ${v_GC_DBHost} -u ${v_GC_DBUser} -p${v_GC_DBPass}

					#	Insert version ACF line
					v_insertNameACF="INSERT INTO wp_postmeta (post_id,meta_key,meta_value) values (\"${v_CS_ID}\",\""_"${v_NameMetaKeyName}\",\"${v_NameMetaKeyID}\")"
					echo ${v_insertNameACF}| mysql -s -N -D ${v_GC_DBName} -h ${v_GC_DBHost} -u ${v_GC_DBUser} -p${v_GC_DBPass}
				#	/NAME	#

				#	STATUS	#
					v_NameMetaKeyName="url/ip_0_installed_on_site_0_plugins/extensions_${currentPluginNum}_status"
					v_NameMetaKeyID='field_5355dafe35774'

					#	Insert version meta line
					v_insertNameMeta="INSERT INTO wp_postmeta (post_id,meta_key,meta_value) values (\"${v_CS_ID}\",\"${v_NameMetaKeyName}\",\"${v_PluginStatus}\")"
					echo ${v_insertNameMeta} | mysql -s -N -D ${v_GC_DBName} -h ${v_GC_DBHost} -u ${v_GC_DBUser} -p${v_GC_DBPass}

					#	Insert version ACF line
					v_insertNameACF="INSERT INTO wp_postmeta (post_id,meta_key,meta_value) values (\"${v_CS_ID}\",\""_"${v_NameMetaKeyName}\",\"${v_NameMetaKeyID}\")"
					echo ${v_insertNameACF}| mysql -s -N -D ${v_GC_DBName} -h ${v_GC_DBHost} -u ${v_GC_DBUser} -p${v_GC_DBPass}
				#	/STATUS	#

				#	UPDATE	#
					v_VersionMetaKeyName="url/ip_0_installed_on_site_0_plugins/extensions_${currentPluginNum}_update"
					v_VersionMetaKeyID='field_5355e651291a4'

					#	Insert version meta line
					v_insertVersionMeta="INSERT INTO wp_postmeta (post_id,meta_key,meta_value) values (\"${v_CS_ID}\",\"${v_VersionMetaKeyName}\",\"${v_PluginUpdate}\")"
					echo ${v_insertVersionMeta}| mysql -s -N -D ${v_GC_DBName} -h ${v_GC_DBHost} -u ${v_GC_DBUser} -p${v_GC_DBPass}

					#	Insert version ACF line
					v_insertVersionACF="INSERT INTO wp_postmeta (post_id,meta_key,meta_value) values (\"${v_CS_ID}\",\""_"${v_VersionMetaKeyName}\",\"${v_VersionMetaKeyID}\")"
					echo ${v_insertVersionACF}| mysql -s -N -D ${v_GC_DBName} -h ${v_GC_DBHost} -u ${v_GC_DBUser} -p${v_GC_DBPass}
				#	/UPDATE	#


				#	VERSION	#
					v_VersionMetaKeyName="url/ip_0_installed_on_site_0_plugins/extensions_${currentPluginNum}_version"
					v_VersionMetaKeyID='field_534d7b125d3ba'

					#	Insert version meta line
					v_insertVersionMeta="INSERT INTO wp_postmeta (post_id,meta_key,meta_value) values (\"${v_CS_ID}\",\"${v_VersionMetaKeyName}\",\"${v_PluginVersion}\")"
					echo ${v_insertVersionMeta}| mysql -s -N -D ${v_GC_DBName} -h ${v_GC_DBHost} -u ${v_GC_DBUser} -p${v_GC_DBPass}

					#	Insert version ACF line
					v_insertVersionACF="INSERT INTO wp_postmeta (post_id,meta_key,meta_value) values (\"${v_CS_ID}\",\""_"${v_VersionMetaKeyName}\",\"${v_VersionMetaKeyID}\")"
					echo ${v_insertVersionACF}| mysql -s -N -D ${v_GC_DBName} -h ${v_GC_DBHost} -u ${v_GC_DBUser} -p${v_GC_DBPass}
				#	/VERSION	#

				let currentPluginNum=currentPluginNum+1
			done

			totalPlugins=$( wp --path=${v_fullWPPath} plugin list --format=csv | tail -n+2 | wc -l )

				v_urlIPName="url/ip_0_installed_on_site_0_plugins/extensions"
				v_urlIPKey='field_534d7af05d3b7'

					#	Insert version meta line
					v_urlIPLine="INSERT INTO wp_postmeta (post_id,meta_key,meta_value) values (\"${v_CS_ID}\",\"${v_urlIPName}\",\"${totalPlugins}\")"
					echo ${v_urlIPLine}| mysql -s -N -D ${v_GC_DBName} -h ${v_GC_DBHost} -u ${v_GC_DBUser} -p${v_GC_DBPass}

					#	Insert version ACF line
					v_urlIPLine="INSERT INTO wp_postmeta (post_id,meta_key,meta_value) values (\"${v_CS_ID}\",\""_"${v_urlIPName}\",\"${v_urlIPKey}\")"
					echo ${v_urlIPLine}| mysql -s -N -D ${v_GC_DBName} -h ${v_GC_DBHost} -u ${v_GC_DBUser} -p${v_GC_DBPass}
		}

		function hasWordpress()
		{
			#	Function to check if WP is installed at all
			v_WPInstalled=$(find ${HOME} -name wp-config.php)

			return $?
		}

		function getWpPath ()
		{
			#	Function used to get the actual path of the WP installation
			v_installDir=$(find ${HOME} -name wp-config.php)

			v_fullWPPath=$( echo ${v_installDir} | sed s/wp-config.php// )
			# v_fullWPPath=`echo ${v_installDir}`

			return $?
		}

		function getWpURL ()
		{
			v_CSURL=$(wp --path=${v_fullWPPath} option get siteurl)

			return $?
		}

		function getCurrentWpVersion ()
		{
			#	Function to get the verion of WP installation
			v_CS_WPVersion=$(wp --path=${v_fullWPPath} core version)

			return $?
		}

		function isWPPublic ()
		{
			#	Function to check if current installation is hidden or not
			v_WPisPublic=`wp option --path=${v_fullWPPath} get blog_public`

			if [[ x"${v_WPisPublic}" == x"0" ]]; then
				v_WPisPublic=1
			else:
				v_WPisPublic=0
			fi
			return $?
		}

		function v_WpGzip ()
		{
			#	Function to check if gzip compression is enabled for the current site
			v_WPgzipCompression=`wp option --path=${v_fullWPPath} get gzipcompression`

			return $?
		}

		function getWpEmail ()
		{
			#	Function used to get the WP Admin Email
			v_WPadminEmail=`wp --path=${v_fullWPPath} option get admin_email`

			return $?
		}

		function getGTMetrix ()
		{
			# Using gtmatrix API, we will scan the site for page load speed information / grades
			echo '++  Checking page speed / score using gtMetrix';

			test_id=`curl --silent --user ${g_GTMETRIX_USER}:${g_GTMETRIX_KEY} --form url=${v_CSURL} --form x-metrix-adblock=0 https://gtmetrix.com/api/0.1/test | jq -r .test_id`
			state="Unknown"
			loop_run_time_secs=0

			while [[ "$state" != "completed" && $loop_run_time_secs < 60 ]]
			do
				results=`curl --silent --user ${g_GTMETRIX_USER}:${g_GTMETRIX_KEY} https://gtmetrix.com/api/0.1/test/$test_id`
				state=`echo $results | jq -r .state`
				echo "${state} ...\r"
				sleep 6
				loop_run_time_secs=$((loop_run_time_secs + 6))
			done

			page_load_time=`echo $results | jq -r .results.page_load_time`
			html_bytes=`echo $results | jq -r .results.html_bytes`
			page_elements=`echo $results | jq -r .results.page_elements`
			report_url=`echo $results | jq -r .results.report_url`
			html_load_time=`echo $results | jq -r .results.html_load_time`
			page_bytes=`echo $results | jq -r .results.page_bytes`
			pagespeed_score=`echo $results | jq -r .results.pagespeed_score`
			yslow_score=`echo $results | jq -r .results.yslow_score`

			# Page Load Time, HTML Bytes, Page Elements, HTML Load Time, Page Bytes, PageSpeed Score, ySlow Score, Report URL

				v_DeleteString="DELETE FROM wp_postmeta WHERE post_id=\"${v_CS_ID}\" AND meta_key LIKE \"page_speed_score\""
				echo ${v_DeleteString}| mysql -s -N -D ${v_GC_DBName} -h ${v_GC_DBHost} -u ${v_GC_DBUser} -p${v_GC_DBPass}
				v_DeleteString="DELETE FROM wp_postmeta WHERE post_id=\"${v_CS_ID}\" AND meta_key LIKE \"yslow_score\""
				echo ${v_DeleteString}| mysql -s -N -D ${v_GC_DBName} -h ${v_GC_DBHost} -u ${v_GC_DBUser} -p${v_GC_DBPass}
				v_DeleteString="DELETE FROM wp_postmeta WHERE post_id=\"${v_CS_ID}\" AND meta_key LIKE \"load_speed\""
				echo ${v_DeleteString}| mysql -s -N -D ${v_GC_DBName} -h ${v_GC_DBHost} -u ${v_GC_DBUser} -p${v_GC_DBPass}
				v_DeleteString="DELETE FROM wp_postmeta WHERE post_id=\"${v_CS_ID}\" AND meta_key LIKE \"report_url\""
				echo ${v_DeleteString}| mysql -s -N -D ${v_GC_DBName} -h ${v_GC_DBHost} -u ${v_GC_DBUser} -p${v_GC_DBPass}



			#	Insert version ACF line
			v_metaKey="page_speed_score"
			v_metaKeyID='field_53576151474bc'
				v_insertVersionMeta="INSERT INTO wp_postmeta (post_id,meta_key,meta_value) values (\"${v_CS_ID}\",\"${v_metaKey}\",\"${pagespeed_score}\")"
				echo ${v_insertVersionMeta}| mysql -s -N -D ${v_GC_DBName} -h ${v_GC_DBHost} -u ${v_GC_DBUser} -p${v_GC_DBPass}

				#	Insert version ACF line
				v_insertVersionACF="INSERT INTO wp_postmeta (post_id,meta_key,meta_value) values (\"${v_CS_ID}\",\""_"${v_metaKey}\",\"${v_metaKeyID}\")"
				echo ${v_insertVersionACF}| mysql -s -N -D ${v_GC_DBName} -h ${v_GC_DBHost} -u ${v_GC_DBUser} -p${v_GC_DBPass}

			#	Insert version ACF line
			v_metaKey="yslow_score"
			v_metaKeyID='field_53576179474bd'
				v_insertVersionMeta="INSERT INTO wp_postmeta (post_id,meta_key,meta_value) values (\"${v_CS_ID}\",\"${v_metaKey}\",\"${yslow_score}\")"
				echo ${v_insertVersionMeta}| mysql -s -N -D ${v_GC_DBName} -h ${v_GC_DBHost} -u ${v_GC_DBUser} -p${v_GC_DBPass}

				#	Insert version ACF line
				v_insertVersionACF="INSERT INTO wp_postmeta (post_id,meta_key,meta_value) values (\"${v_CS_ID}\",\""_"${v_metaKey}\",\"${v_metaKeyID}\")"
				echo ${v_insertVersionACF}| mysql -s -N -D ${v_GC_DBName} -h ${v_GC_DBHost} -u ${v_GC_DBUser} -p${v_GC_DBPass}

			#	Insert version ACF line
			v_metaKey="load_speed"
			v_metaKeyID='field_5357618f474be'
				v_insertVersionMeta="INSERT INTO wp_postmeta (post_id,meta_key,meta_value) values (\"${v_CS_ID}\",\"${v_metaKey}\",\"${page_load_time}\")"
				echo ${v_insertVersionMeta}| mysql -s -N -D ${v_GC_DBName} -h ${v_GC_DBHost} -u ${v_GC_DBUser} -p${v_GC_DBPass}

				#	Insert version ACF line
				v_insertVersionACF="INSERT INTO wp_postmeta (post_id,meta_key,meta_value) values (\"${v_CS_ID}\",\""_"${v_metaKey}\",\"${v_metaKeyID}\")"
				echo ${v_insertVersionACF}| mysql -s -N -D ${v_GC_DBName} -h ${v_GC_DBHost} -u ${v_GC_DBUser} -p${v_GC_DBPass}

			#	Insert version ACF line
			v_metaKey="report_url"
			v_metaKeyID='field_53576198474bf'
				v_insertVersionMeta="INSERT INTO wp_postmeta (post_id,meta_key,meta_value) values (\"${v_CS_ID}\",\"${v_metaKey}\",\"${report_url}\")"
				echo ${v_insertVersionMeta}| mysql -s -N -D ${v_GC_DBName} -h ${v_GC_DBHost} -u ${v_GC_DBUser} -p${v_GC_DBPass}

				#	Insert version ACF line
				v_insertVersionACF="INSERT INTO wp_postmeta (post_id,meta_key,meta_value) values (\"${v_CS_ID}\",\""_"${v_metaKey}\",\"${v_metaKeyID}\")"
				echo ${v_insertVersionACF}| mysql -s -N -D ${v_GC_DBName} -h ${v_GC_DBHost} -u ${v_GC_DBUser} -p${v_GC_DBPass}

			return ${?}

		}

		function checkForAnalytics()
		{
			# Check if google analytics code is installed, if so retrieve UA code
			cat ${g_RESPONSEFILE} | grep '_setAccount' | awk -F', ' '{ print $2 }'|cut -d"'" -f2 2>&1

			if [[ x"${?}" == x"0" ]]
			then
				analytics_status=`cat ${g_RESPONSEFILE} | grep '_setAccount' | awk -F', ' '{ print $2 }'|cut -d"'" -f2 2>&1`
			else
				analytics_status="None"
			fi


			return ${v_analyticsString}
		}

		function CurlInstall ()
		{
			curl "${1}" -i -s > ${g_RESPONSEFILE}

			g_RESPONSEFILE=`echo ${g_RESPONSEFILE}`

			statuscode=$( grep HTTP "${g_RESPONSEFILE}" | sed 's/HTTP\/1\.[01] \(.*\)/\1/')
			if [[ $statuscode =~ ^200 ]];	then
				#do stuff
				checkPageSpeed
				checkGTmetrix
				checkForAnalytics
			fi
		}

		function updateLastScanned ()
		{
			#	Setup string for deleting old plugin information
				v_DeleteString="DELETE FROM wp_postmeta WHERE post_id=\"${v_CS_ID}\" AND meta_key LIKE \"last_scanned\""
				echo ${v_DeleteString}| mysql -s -N -D ${v_GC_DBName} -h ${v_GC_DBHost} -u ${v_GC_DBUser} -p${v_GC_DBPass}


			v_metaKey="last_scanned"
			v_metaKeyID='field_535761a0474c0'
				v_insertVersionMeta="INSERT INTO wp_postmeta (post_id,meta_key,meta_value) values (\"${v_CS_ID}\",\"${v_metaKey}\",\"${v_CurrentDateTime}\")"
				echo ${v_insertVersionMeta}| mysql -s -N -D ${v_GC_DBName} -h ${v_GC_DBHost} -u ${v_GC_DBUser} -p${v_GC_DBPass}

				v_insertVersionACF="INSERT INTO wp_postmeta (post_id,meta_key,meta_value) values (\"${v_CS_ID}\",\""_"${v_metaKey}\",\"${v_metaKeyID}\")"
				echo ${v_insertVersionACF}| mysql -s -N -D ${v_GC_DBName} -h ${v_GC_DBHost} -u ${v_GC_DBUser} -p${v_GC_DBPass}

			return $?
		}
	######	/Functions ######

	#	Take in first operator and set that as our current username
	v_SiteAccount=${1}

	if [[ x"${1}" == x"" ]]; then
		echo "No account specified....  Automatically determining...."
		v_SiteAccount=`whoami`
	fi
	#	GC	==	GigaCode

	v_GC_SITEDIR='/home/gigacode/public_html'

	#	Grab variables from wp-config for GigaCode
		# v_GC_DBHost=`cat "${v_GC_SITEDIR}/wp-config.php"|grep DB_HOST|grep -Po "(?<=')[^']+(?=')"|tail -n 1`
		# v_GC_DBUser=`cat "${v_GC_SITEDIR}/wp-config.php"|grep DB_USER|grep -Po "(?<=')[^']+(?=')"|tail -n 1`
		# v_GC_DBPass=`cat "${v_GC_SITEDIR}/wp-config.php"|grep DB_PASSWORD|grep -Po "(?<=')[^']+(?=')"|tail -n 1`
		# v_GC_DBName=`cat "${v_GC_SITEDIR}/wp-config.php"|grep DB_NAME|grep -Po "(?<=')[^']+(?=')"|tail -n 1`

	#	Setup DB variables for GigaCode
		v_GC_DBHost='localhost'
		v_GC_DBUser='gigacode_wp597'
		v_GC_DBPass='0i)u.P76Sl'
		v_GC_DBName='gigacode_wp597'

	v_CS_SITEDIR="/home/${v_SiteAccount}/public_html/"

	#	Grab variables from wp-config for Current Site
		v_CS_DBHost=`cat "${v_CS_SITEDIR}/wp-config.php"|grep DB_HOST|grep -Po "(?<=')[^']+(?=')"|tail -n 1`
		v_CS_DBUser=`cat "${v_CS_SITEDIR}/wp-config.php"|grep DB_USER|grep -Po "(?<=')[^']+(?=')"|tail -n 1`
		v_CS_DBPass=`cat "${v_CS_SITEDIR}/wp-config.php"|grep DB_PASSWORD|grep -Po "(?<=')[^']+(?=')"|tail -n 1`
		v_CS_DBName=`cat "${v_CS_SITEDIR}/wp-config.php"|grep DB_NAME|grep -Po "(?<=')[^']+(?=')"|tail -n 1`


		getCurrentServer
		echo ${v_CurrentHost}

		hasWordpress
		echo ${v_WPInstalled}

		getWpURL

		getWpPath
		echo ${v_fullWPPath}

		getCurrentWpVersion
		echo ${v_CS_WPVersion}

		isWPPublic
		echo ${v_WPisPublic}

		v_WpGzip
		echo ${v_WPgzipCompression}

		getWpEmail
		echo ${v_WPadminEmail}

		getCurrentSitePostID ${v_SiteAccount}
		echo ${v_CS_ID}

		if [[ x"${v_CS_ID}" == x"" ]]; then
			echo "No account found / made in GigaCode....Exiting"
		else
			deleteWpData
			insertWPMeta
			insertPlugins
			getGTMetrix
			updateLastScanned
		fi

			#$(echo "SELECT ID FROM wp_posts WHERE post_title = \"${v_SiteAccount}\" AND post_status=\"publish\"" | mysql -s -N -D ${v_GC_DBName} -h ${v_GC_DBHost} -u ${v_GC_DBUser} -p${v_GC_DBPass})