#!/bin/sh

if [ "$(use 'y' 'n')" = "n" ]; then
    runDeps=$(
		scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/lib/php/extensions \
			| tr ',' '\n' \
			| sort -u \
			| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }'
	)

    apk add --no-network --virtual .typecho-phpexts-rundeps $runDeps;
    apk del --no-network .build-deps
else
    savedAptMark=$1
    apt-mark auto '.*' > /dev/null
	apt-mark manual $savedAptMark
	ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
		| awk '/=>/ { print $3 }' \
		| sort -u \
		| xargs -r dpkg-query -S \
		| cut -d: -f1 \
		| sort -u \
		| xargs -rt apt-mark manual
	
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false
	rm -rf /var/lib/apt/lists/*
fi
