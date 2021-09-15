#!/bin/sh

# download code
curl -o typecho.zip -fL $URL
unzip typecho.zip -d /app
mkdir -p /app/usr/uploads && chmod 755 /app/usr/uploads
rm -rf typecho.zip

curl -o langs.zip -fL https://nightly.link/typecho/languages/workflows/ci/master/langs.zip
unzip langs.zip -d /app/usr/langs
rm -rf langs.zip

chown -Rf www-data:www-data /app

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
