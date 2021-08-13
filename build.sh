#!/bin/bash

version="7.4"
type="php"
os="debian"

display_usage_and_exit() {
  echo "Usage: $(basename "$0") [-v <version>] [-o <os>] <type>" >&2
  echo "Arguments:" >&2
  echo "type REQUIRED: The type of the container runs on" >&2
  echo "-v OPTIONAL: The php version, defaults is '${version}'" >&2
  echo "-o OPTIONAL: The os type, defaults is '${os}', must be 'debian' or 'alpine'" >&2
  exit 1
}

while getopts ':v:p:o:' arg
do
    case ${arg} in
        v) version=${OPTARG};;
        o) os=${OPTARG};;
        *) display_usage_and_exit
    esac
done

shift $((OPTIND-1))
if [ "$#" -ne 1 ] ; then
  display_usage_and_exit
fi
readonly type="$1"

LEFT=$version
MIDDLE=""
RIGHT=""

cat Dockerfile.base > Dockerfile

if [ ${type} != "php" ]; then
    MIDDLE="-${type}"
    cat "Dockerfile.${type}" >> Dockerfile
fi

if [[ ${os} == "alpine" && ${type} != "apache" ]]; then
    RIGHT="-${os}"
fi

TAG="${LEFT}${MIDDLE}${RIGHT}"

echo $TAG
docker build -t typecho:php${TAG} --no-cache --build-arg TAG=${TAG} .
rm -rf Dockerfile
