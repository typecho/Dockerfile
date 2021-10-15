#!/bin/sh

{
    echo "max_execution_time = ${MAX_EXECUTION_TIME}";
    echo "memory_limit = ${MEMORY_LIMIT}";
    echo "upload_max_filesize = ${MAX_POST_BODY}";
    echo "post_max_size = ${MAX_POST_BODY}";
} > /usr/local/etc/php/conf.d/custom.ini

if [[ ! -z "${TIMEZONE}" && -e "/usr/share/zoneinfo/${TIMEZONE}" ]]; then
    echo "date.timezone = ${TIMEZONE}" >> /usr/local/etc/php/conf.d/custom.ini
    cp /usr/share/zoneinfo/$TIMEZONE /etc/localtime
    echo $TIMEZONE > /etc/timezone
fi

if [ ! -e /app/index.php ]; then
    unzip -q /usr/src/typecho.zip -d /app
    chown -Rf www-data:www-data /app
fi

if [ ! -e /app/usr/uploads ]; then
    mkdir -p /app/usr/uploads
    chmod 755 /app/usr/uploads
    chown -Rf www-data:www-data /app/usr/uploads
fi

if [ ! -e /app/usr/langs ]; then
    unzip -q /usr/src/langs.zip -d /app/usr/langs
    chown -Rf www-data:www-data /app/usr/langs
fi

if [ ! -z "${TYPECHO_INSTALL}" ]; then
    su -p www-data -s /usr/bin/env php /app/install.php
fi