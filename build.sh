#!/bin/bash

version="dev"
php="7.4"
type="php"
os="debian"
generate=0
upload=0
buildx=0

display_usage_and_exit() {
  echo "Usage: $(basename "$0") [-g] [-u] [-x] [-v <typecho version>] [-p <php version>] [-o <os>] <type>" >&2
  echo "Arguments:" >&2
  echo "type REQUIRED: The type of the container runs on" >&2
  echo "-g OPTIONAL: Generate Dockerfile only, default off" >&2
  echo "-u OPTIONAL: Upload to Dockerhub, default off" >&2
  echo "-x OPTIONAL: Setup multi-platform, default off" >&2
  echo "-v OPTIONAL: The typecho version, defaults is '${version}'" >&2
  echo "-p OPTIONAL: The php version, defaults is '${php}'" >&2
  echo "-o OPTIONAL: The os type, defaults is '${os}', must be 'debian' or 'alpine'" >&2
  exit 1
}

while getopts ':ugxv:p:o:' arg
do
    case ${arg} in
        u) upload=1;;
        g) generate=1;;
        x) buildx=1;;
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
URL="https://nightly.link/typecho/typecho/workflows/Typecho-dev-Ci/master/typecho_build.zip"
PLATFORM="linux/386,linux/ppc64le,linux/s390x,linux/amd64,linux/arm64,linux/arm/v7"
PUSH=""

if [ ${type} != "php" ]; then
    MIDDLE="-${type}"
    cat "Dockerfile.${type}" >> Dockerfile
fi

if [[ ${os} == "alpine" && ${type} != "apache" ]]; then
    RIGHT="-${os}"
fi

if [ ${version} != "dev" ]; then
    URL="https://github.com/typecho/typecho/releases/download/v${version}/typecho_build.zip"
fi

if [ ${upload} -eq 1 ]; then
    PUSH="--push"
fi

TAG="${LEFT}${MIDDLE}${RIGHT}"
FILE="Dockerfile.${TAG}"

cat Dockerfile.base > ${FILE}

if [ ${generate} -eq 0 ]; then
    echo $TAG

    if [ ${buildx} -eq 1 ]; then
        docker buildx create --name typecho
        docker buildx use typecho
        docker buildx inspect --bootstrap
    fi

    docker buildx build --platform ${PLATFORM} ${PUSH} -t joyqi/typecho:${version}-php${TAG} --no-cache --build-arg TAG=${TAG} --build-arg URL=${URL} -f ${FILE} .
    rm -rf ${FILE}

    if [ ${buildx} -eq 1 ]; then
        docker buildx stop
        docker buildx rm typecho
    fi
else
    echo $FILE
fi
