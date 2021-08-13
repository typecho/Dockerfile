#!/bin/bash

{
    echo "upload_max_filesize = ${MAX_POST_BODY}";
    echo "post_max_size = ${MAX_POST_BODY}";
} > /usr/local/etc/php/conf.d/max-post-body.ini
