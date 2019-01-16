#! /bin/bash
#----------------------------------------------------------------------------------------------#
# pw-cpanel.sh v0.1 (#0 2016-01-05)                                                           #
#                                                                                              #
# This script will handle changing passwords for cPanel									       #
############################## Modification Log ##############################                 #
# Date          Who             Version         Description
# 20160105      KChase			0.1             Initial Release


	v_MyIP=`dig +short myip.opendns.com @resolver1.opendns.com`

	export ALLOW_PASSWORD_CHANGE=1

	ls -1 /var/cpanel/users | while read v_Username; do
		v_SITEDIR="/home/${v_Username}/public_html/"

		if [[ ${v_Username} == "cf" || ${v_Username} == "cfc" || ${v_Username} == "cfportal" || ${v_Username} == "newcf" ]];then
			continue;
		fi

		# echo	"+		Checking if Magento exists in user directory"
		v_MagentoDir=`find ${v_SITEDIR} -name Mage.php`
		v_hasMagento=$?
		# echo	"+		Checking if WordPress exists in user directory"
		v_WordpressDir=`find ${v_SITEDIR} -name wp-config.php`
		v_hasWP=$?

		if [[ -a ${v_MagentoDir} ]];then
			#echo	"+		Magento Found"
			v_Password=$(</dev/urandom tr -dc '12345!@#$%qwertQWERTasdfgASDFGzxcvbZXCVB' | head -c16; echo "")

			v_MagentoDir=`echo "${v_MagentoDir}" | sed 's^app/Mage.php^^'`
			#v_MagentoVersion=`n98 --root-dir=${v_MagentoDir} --skip-root-check sys:info version`
			v_GSadmin=`n98 admin:user:list --root-dir=${v_MagentoDir} --format=csv|grep "gsadmin"| awk -F',' '{ print $2 }'`


			#echo "Magento,${v_MagentoGSadmin}"
			echo "Posting Magento Data";

			curl -i \
			-H "Accept: application/json" \
			-H "Content-Type:application/json" \
			-X POST --data '{"username":"'"$v_GSadmin"'",
							 "password":"'"$v_Password"'",
							 "platform":"Magento",
							 "location":"'"$v_MyIP"'",
							 "token":""}' http://site.com/v1.0/credentials/update/

				
		fi	


		if [[ -a ${v_WordpressDir} ]];then
			#echo	"+		WordPress Found"
			v_Password=$(</dev/urandom tr -dc '12345!@#$%qwertQWERTasdfgASDFGzxcvbZXCVB' | head -c16; echo "")

			v_WordpressDir=`dirname ${v_WordpressDir}`
			#v_WPVersion=`wp --allow-root --path=${v_WordpressDir} core version`

			v_GSadmin=`wp --allow-root --fields=user_login,user_email --path=${v_WordpressDir} --role=administrator --format=csv user list |grep gsadmin| tail -1|awk -F',' '{ print $1 }'`
			
			if [[ x"${v_GSadmin}" != x"" ]]; then
				v_Status=`wp --allow-root user update ${v_GSadmin} --user_pass=${v_Password} --path=${v_WordpressDir}`
				
				echo "Posting WordPress Data";

				curl -i \
				-H "Accept: application/json" \
				-H "Content-Type:application/json" \
				-X POST --data '{"username":"'"$v_GSadmin"'",
								 "password":"'"$v_Password"'",
								 "platform":"WordPress",
								 "location":"'"$v_MyIP"'",
								 "token":"#$K@DE*(&#$"}' http://site.com/v1.0/credentials/update/
		    fi
		fi


		#echo "https://${v_MyIP}:2083 ${v_MyIP} ${v_Username} ${v_Password}"
	done