#!/bin/bash

find /home/ -name version.php | while read line; do
#    echo "Processing file '$line'"

	if grep --quiet wp ${line}; then
	

			users=$(wp user list --format="csv" --fields="user_email"|grep -i rachel)
			for user in $users
			do
				
				wp user update $user --role="subscriber" --allow-root --path=${line}
			done

		
	fi
done