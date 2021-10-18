#!/bin/<shell>

check_and_copy() {
    if [ ! -e /app/$1 ]; then
        cp -Rf /usr/src/typecho/$1 /app/$1
        chown -Rf www-data:www-data /app/$1
    fi
}

make_and_copy() {
    if [ ! -e /app/$1 ]; then
        mkdir -p /app/$1
        cp -Rf /usr/src/typecho/$1/* /app/$1/
        chown -Rf www-data:www-data /app/$1
    fi
}

check_and_make() {
    if [ ! -e /app/$1 ]; then
        mkdir -p /app/$1
        chown -Rf www-data:www-data /app/$1
    fi

    if [ -n "$2" ]; then
        chmod $2 /app/$1
    fi
}

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

chown www-data:www-data /app
check_and_copy 'admin'
check_and_copy 'install'
check_and_copy 'var'
check_and_copy 'index.php'
check_and_copy 'install.php'
check_and_make 'usr'
make_and_copy 'usr/themes'
make_and_copy 'usr/plugins'
make_and_copy 'usr/langs'
check_and_make 'usr/uploads' '755'

if [ ! -z "${TYPECHO_INSTALL}" ]; then
    su -p www-data -s /usr/bin/env php /app/install.php
fi

if [ "$1" = "apache" ]; then
    apachectl -D FOREGROUND
elif [ "$1" = "fpm" ]; then
    php-fpm
elif [ "$1" = "cli" ]; then
    su -p www-data -s /bin/<shell> -c '/usr/bin/env php'
else
    su -p www-data -s /bin/<shell> -c '/usr/bin/env php -S 0.0.0.0:80 -t /app'
fi