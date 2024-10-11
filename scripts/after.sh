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
    extdir="$(php -r 'echo ini_get("extension_dir");')"; \
    ldd "$extdir"/*.so \
      | awk '/=>/ { print $3 }' \
      | awk '{print $1} {system("realpath " $1)}' \
      | sort -u \
      | xargs -r dpkg-query -S \
      | cut -d: -f1 \
      | sort -u \
      | xargs -rt apt-mark manual
	
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false
    rm -rf /var/lib/apt/lists/*;
    ldd "$extdir"/*.so | grep -qzv "=> not found" || (echo "Sanity check failed: missing libraries:"; ldd "$extdir"/*.so | grep " => not found"; exit 1); \
    ldd "$extdir"/*.so | grep -q "libzip.so.* => .*/libzip.so.*" || (echo "Sanity check failed: libzip.so is not referenced"; ldd "$extdir"/*.so; exit 1);
fi
