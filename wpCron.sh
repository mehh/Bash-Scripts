#!/bin/bash
# Copyright © 2016 Bjørn Johansen
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See http://www.wtfpl.net/ for more details.
 
WP_PATH="/home/ullunew/public_html/"
 
# Check if WP-CLI is available
if ! hash wp 2>/dev/null; then
    echo "WP-CLI is not available"
    exit
fi
 
# If WordPress isn’t installed here, we bail
if ! $(wp core is-installed --path="$WP_PATH" --quiet); then
    echo "WordPress is not installed here: ${WP_PATH}"
    exit
fi
 
wp post update 134 --post_status=draft --path="$WP_PATH"