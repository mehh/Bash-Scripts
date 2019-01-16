#!/bin/bash

yum -y install optipng;
yum -y install jpegoptim;

find . -iname *.jpg | xargs jpegoptim --max=90 --all-progressive --strip-all --strip-com --strip-exif --strip-iptc --strip-icc &
find . -type f -iname "*.png" -print0 | xargs -I {} -0 optipng -o5 -quiet -keep -preserve -log optipng.log "{}" &