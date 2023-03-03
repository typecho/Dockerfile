#!/bin/sh

if [ "$1" = "dev" ]; then
    echo "Building development image, ignoring download source code"
else
    echo "Downloading source code: $1"
    curl -o /usr/src/typecho.zip -fL $1
    unzip -q /usr/src/typecho.zip -d /usr/src/typecho && chown -Rf www-data:www-data /usr/src/typecho && rm -rf /usr/src/typecho.zip
    curl -o /usr/src/langs.zip -fL https://github.com/typecho/languages/releases/download/ci/langs.zip
    unzip -q /usr/src/langs.zip -d /usr/src/typecho/usr/langs && chown -Rf www-data:www-data /usr/src/typecho/usr/langs && rm -rf /usr/src/langs.zip
fi
