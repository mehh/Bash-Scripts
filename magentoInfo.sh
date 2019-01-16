#!/bin/bash
#	Script by Kris Chase
#	http://krischase.com
#
#	Find all directories that have magento installed
#	Get versions of installed Magento Instances
#	Get edition (Community / Enterprise) of Magento Instances


for i in $( find /home/ -name Mage.php ); 
do
	#	Find Magento Installs
    	v_Username=`echo "${i}" | awk -F/ '{ print $3}'`

    #	Get Magento base Dir
    	v_Basedir=`echo "${i}" | sed 's^app/Mage.php^^'`

    #	Get versions of installed Magento instances
    	v_Version=`php -r "require \"${i}\"; echo Mage::getVersion(); "`

    #	Check if Magento is Community Edition or Enterprise Edition
    	#v_Edition=`cat ${v_Basedir}RELEASE_NOTES.txt | grep '/ce-' > /dev/null`
    	v_Edition=`cat ${v_Basedir}index.php | grep 'enterprise-edition' > /dev/null`
    	v_Status="${?}"
    	if [[ x"${v_Status}" == x"0" ]];then
    		v_Edition='Enterprise'
    	else
    		v_Edition='Community'
    	fi

    # #	Check if patches are installed
    # 	v_5344=`cat ${v_Basedir}app/etc/applied.patches.list | grep 'SUPEE-5344' > /dev/null`
    # 	v_Status="${?}"
    # 	if [[ x"${v_Status}" == x"0" ]];then
    # 		v_5344_Status='Installed'
    # 	else
    # 		v_5344_Status='Not Installed'
    # 	fi

    # 	v_5994=`cat ${v_Basedir}app/etc/applied.patches.list | grep 'SUPEE-5994' > /dev/null`
    # 	v_Status="${?}"
    # 	if [[ x"${v_Status}" == x"0" ]];then
    # 		v_5994_Status='Installed'
    # 	else
    # 		v_5994_Status='Not Installed'
    # 	fi

   #	Get domain name associated with username
   		#v_Domain=`grep ": ${v_Username}" /etc/userdomains | cut -d: -f1|grep dev3`

    #	Print Results
        # echo "${v_Username},${v_Version},${v_Edition},${v_Domain},${v_5344_Status},${v_5994_Status}"
        echo "${v_Username},${v_Version},${v_Edition},${v_Domain}"
done
