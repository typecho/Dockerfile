#!/bin/bash

readonly php="$1"
readonly version="$2"

# build for debian
./build.sh -u -v ${version} -p ${php} php
./build.sh -u -v ${version} -p ${php} cli
./build.sh -u -v ${version} -p ${php} fpm
./build.sh -u -v ${version} -p ${php} apache

# build for alpine
./build.sh -u -v ${version} -p ${php} -o alpine php
./build.sh -u -v ${version} -p ${php} -o alpine cli
./build.sh -u -v ${version} -p ${php} -o alpine fpm
./build.sh -u -v ${version} -p ${php} -o alpine apache
