#!/bin/sh

IS_APLINE=$(cat /etc/os-release | grep "NAME=" | grep -ic "Alpine")

if [ ${IS_APLINE} -gt 0 ]; then
    if [ "$2" != "-" ]; then
        echo $2
    fi
else
    if [ "$1" != "-" ]; then
        echo $1
    fi
fi
