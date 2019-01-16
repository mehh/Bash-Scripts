#!/bin/bash
#   Script by Kris Chase
#   https://krischase.com
#
#   Quick and dirty script to get http status on domain name

while getopts "f:h" OPTIONS; do
   case ${OPTIONS} in
      f ) v_File=$OPTARG ;;
      h ) help ;;
      * ) echo "Unknown option" 1>&2; help; exit 2 ;; # Default
   esac
done

while read LINE; do
(
  curl -o /dev/null --silent --head --write-out '%{http_code}' "${LINE}"
  echo " $LINE"
) &
done < ${v_File}
