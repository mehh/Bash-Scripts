#!/bin/bash
#   magento_image_import.sh
# This script assumes that it is running in a parent folder
# which contains folders named by sku
# that contain images in each respective directory

  v_ImageDir=''

  echo 'sku,base_image,base_image_label,small_image,small_image_label,thumbnail_image,thumbnail_image_label,swatch_image,swatch_image_label'

# Loop through and get all directories from current directory
shopt -s dotglob
find . -type f -exec file {} \; | grep -o -P '^.+: \w+ image' | while IFS= read -r v_directory; do
  # echo "$directory"

  v_count=1

  for v_file in ${v_directory}/*; do
    # grab the filename, split out the image portion
    v_filename=`echo ${v_file} |awk -F':' '{ print $1 }'`
    v_filename=`basename "$v_filename"`
    v_SKU=`echo ${v_filename} | awk -F'_' '{  print $1 }'`

    if [[ ${v_SKU} != 'JPEG' ]];then
      if [[ ${v_filename} != '*' ]];then
        # if grep -qP "\b\b" productlist.txt; then
          if [ "${v_count}" == "1" ];then
            echo ${v_SKU},${v_ImageDir}/${v_filename},${v_filename},${v_ImageDir}/${v_filename},${v_filename},${v_ImageDir}/${v_filename},${v_filename},${v_ImageDir}/${v_filename},${v_filename}
          else
            echo ${v_SKU},${v_ImageDir}/${v_filename},${v_filename},${v_ImageDir}/${v_filename},${v_filename},${v_ImageDir}/${v_filename},${v_filename},${v_ImageDir}/${v_filename},${v_filename}
          fi
        # fi
      fi
    fi

    let v_count+=1
  done
done
