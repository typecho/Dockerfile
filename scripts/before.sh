#!/bin/sh

if [ "$(use 'y' 'n')" = "y" ]; then
    echo "$(apt-mark showmanual)"
fi
