#!/bin/bash


while read p; do


v_domain=`echo $p| cut -d, -f1`
v_destination=`echo $p| cut -d, -f2`


echo "RewriteCond %{HTTP_HOST} ^${v_domain} [NC,OR]"
echo "RewriteCond %{HTTP_HOST} ^www.${v_domain} [NC]"
echo "aaaa${v_destination}bbbb"


done < $1