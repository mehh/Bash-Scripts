#!/bin/bash
#   magento_image_import.sh
# This script assumes that it is running in a parent folder
# which contains folders named by sku
# that contain images in each respective directory

  v_ImageDir=''

  echo 'sku,base_image,base_image_label,small_image,small_image_label,thumbnail_image,thumbnail_image_label,swatch_image,swatch_image_label'

# Loop through and get all directories from current directory
shopt -s dotglob
find * -prune -type d | while IFS= read -r v_directory; do
    # echo "$directory"

  v_count=1

  for v_file in ${v_directory}/*; do
    v_filename="${v_file%.*}"
    v_filename=`basename "$v_filename"`

    if grep -qP "\b${v_directory}\b" productlist.txt; then
      if [ "${v_count}" == "1" ];then
        echo ${v_directory},${v_ImageDir}${v_directory}/${v_file##*/},${v_filename},${v_ImageDir}${v_directory}/${v_file##*/},${v_filename},${v_ImageDir}${v_directory}/${v_file##*/},${v_filename},${v_ImageDir}${v_directory}/${v_file##*/},${v_filename}
      else
        echo ${v_directory},${v_ImageDir}${v_directory}/${v_file##*/},${v_filename},${v_ImageDir}${v_directory}/${v_file##*/},${v_filename},${v_ImageDir}${v_directory}/${v_file##*/},${v_filename},${v_ImageDir}${v_directory}/${v_file##*/},${v_filename}
      fi
    fi

    let v_count+=1
  done
done
