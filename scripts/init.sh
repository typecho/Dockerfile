#!/bin/sh

{
    echo "max_execution_time = ${MAX_EXECUTION_TIME}";
    echo "memory_limit = ${MEMORY_LIMIT}";
    echo "upload_max_filesize = ${MAX_POST_BODY}";
    echo "post_max_size = ${MAX_POST_BODY}";
    echo "date.timezone = ${TIMEZONE}";
} > /usr/local/etc/php/conf.d/custom.ini

cp "/usr/share/zoneinfo/${TIMEZONE}" /etc/localtime
echo ${TIMEZONE} > /etc/timezone
