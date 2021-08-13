#!/bin/bash

IS_APLINE=$(cat /etc/os-release | grep "NAME=" | grep -ic "Alpine")

if [ ${IS_APLINE} -gt 0 ]; then
    echo $2
else
    echo $1
fi
