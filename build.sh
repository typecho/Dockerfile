#!/bin/bash

version="nightly"
php="7.4"
type="php"
os="debian"
generate=0
upload=0
buildx=0
setup_buildx=0
dockerhub_username=${dockerhub_username:-joyqi}

display_usage_and_exit() {
  echo "Usage: $(basename "$0") [-g] [-u] [-x] [-s] [-v <typecho version>] [-p <php version>] [-o <os>] <type>" >&2
  echo "Arguments:" >&2
  echo "type REQUIRED: The type of the container runs on" >&2
  echo "-g OPTIONAL: Generate Dockerfile only, default off" >&2
  echo "-u OPTIONAL: Upload to Dockerhub, default off" >&2
  echo "-x OPTIONAL: Support multi-platform, default off" >&2
  echo "-s OPTIONAL: Setup multi-platform, default off" >&2
  echo "-v OPTIONAL: The typecho version, defaults is '${version}'" >&2
  echo "-p OPTIONAL: The php version, defaults is '${php}'" >&2
  echo "-o OPTIONAL: The os type, defaults is '${os}', must be 'debian' or 'alpine'" >&2
  exit 1
}

while getopts ':ugxsv:p:o:' arg
do
    case ${arg} in
        u) upload=1;;
        g) generate=1;;
        x) buildx=1;;
        s) setup_buildx=1;;
        v) version=${OPTARG};;
        p) php=${OPTARG};;
        o) os=${OPTARG};;
        *) display_usage_and_exit
    esac
done

shift $((OPTIND-1))
if [ "$#" -ne 1 ] ; then
  display_usage_and_exit
fi
readonly type="$1"

LEFT=$php
MIDDLE=""
RIGHT=""
URL="https://github.com/typecho/typecho/releases/download/ci/typecho.zip"
PLATFORM="linux/arm/v7,linux/amd64,linux/arm64"
PUSH=""
CONFIG="-dir=/usr/include/"
BUILDX="build"
PHP8_SOCKETS_WORKAROUND=""
PHP_EXTENSION="gd bcmath exif zip mysqli pdo_mysql pdo_pgsql tokenizer opcache"

cat Dockerfile.base > Dockerfile

if [ ${type} != "php" ]; then
    MIDDLE="-${type}"
    cat "Dockerfile.${type}" >> Dockerfile
else
    cat "Dockerfile.default" >> Dockerfile
fi

if [[ ${os} == "alpine" && ${type} != "apache" ]]; then
    RIGHT="-${os}"
fi

if [ ${version} == "dev" ]; then
    URL="dev"
elif [ ${version} != "nightly" ]; then
    URL="https://github.com/typecho/typecho/releases/download/v${version}/typecho.zip"
fi

if [ ${php} != "7.3" ]; then
    CONFIG=""
fi

# add workaround for php 8 build error
if [[ ${php} == "8.0" || ${php} == "8.1" || ${php} == "8.2" ]]; then
    PHP8_SOCKETS_WORKAROUND="-D_GNU_SOURCE"
fi

# disable tokenzier extension for php 8.1
if [[ ${php} == "8.1" || ${php} == "8.2" ]]; then
    PHP_EXTENSION="gd bcmath exif zip mysqli pdo_mysql pdo_pgsql opcache"
fi

TAG="${LEFT}${MIDDLE}${RIGHT}"

if [ ${generate} -eq 0 ]; then
    echo $TAG

    if [ ${setup_buildx} -eq 1 ]; then
        docker buildx create --name typecho
        docker buildx use typecho
        docker buildx inspect --bootstrap
    fi

    if [ ${buildx} -eq 1 ]; then
        BUILDX="buildx build --platform ${PLATFORM} ${PUSH}"

        if [ ${upload} -eq 1 ]; then
            BUILDX="${BUILDX} --push"
        fi
    fi

    docker ${BUILDX} --no-cache -t ${dockerhub_username}/typecho:${version}-php${TAG} --build-arg TAG=${TAG} --build-arg URL=${URL} --build-arg CONFIG="${CONFIG}" --build-arg PHP_EXTENSION="${PHP_EXTENSION}" --build-arg PHP8_SOCKETS_WORKAROUND="${PHP8_SOCKETS_WORKAROUND}" .

    if [ ${setup_buildx} -eq 1 ]; then
        docker buildx stop
        docker buildx rm typecho
    fi

    if [[ ${buildx} -eq 0 && ${upload} -eq 1 ]]; then
        docker push ${dockerhub_username}/typecho:${version}-php${TAG}
    fi
    
    rm -rf Dockerfile
else
    echo "TAG=${TAG}" >> $GITHUB_OUTPUT
    echo "URL=${URL}" >> $GITHUB_OUTPUT
    echo "CONFIG=${CONFIG}" >> $GITHUB_OUTPUT
    echo "PLATFORM=${PLATFORM}" >> $GITHUB_OUTPUT
    echo "PHP8_SOCKETS_WORKAROUND=${PHP8_SOCKETS_WORKAROUND}" >> $GITHUB_OUTPUT
    echo "PHP_EXTENSION=${PHP_EXTENSION}" >> $GITHUB_OUTPUT
    echo "VERSION=${dockerhub_username}/typecho:${version}-php${TAG}" >> $GITHUB_OUTPUT
fi
