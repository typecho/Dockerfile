#!/bin/bash

if [[ $1 = "" ]]; then
    cat <<EOF
name: Build Typecho Docker Image

on:
  workflow_dispatch:
    inputs:
      version:
        description: 'Typecho version'
        required: true

jobs:
EOF
fi

os=("debian" "alpine")
php=("7.3" "7.4" "8.0")
platform=("php" "cli" "fpm" "apache")

for o in ${os[@]}
do
    for p in ${php[@]}
    do
        last=""
        for f in ${platform[@]}
        do
            id="build_${p//./}_${f}_${o}"
            concurrency="build_${o}_${p//./}"
            needs=""

            if [[ ${last} != "" && $1 = "" ]]; then
                needs=$(cat <<EOF
    needs:
        - ${last}
EOF)
            fi

            last=$id

            if [[ ${o} != "alpine" || ${f} != "apache" ]]; then
                if [[ $1 = "" ]]; then
                    cat <<EOF
  ${id}:
    concurrency: ${concurrency}
    runs-on: ubuntu-latest
${needs}
    steps:
      - name: Checkout the repo 
        uses: actions/checkout@v2 
      - name: Set up QEMU
        uses: docker/setup-qemu-action@v1
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v1
      - name: Login to DockerHub
        uses: docker/login-action@v1 
        with:
          username: \${{ secrets.DOCKERHUB_USERNAME }}
          password: \${{ secrets.DOCKERHUB_TOKEN }}
      - name: Generate Dockerfile
        id: generate
        run: |
          ./build.sh -g -v \${{ github.event.inputs.version }} -p ${p} -o ${o} ${f}
      - name: Build and push
        uses: docker/build-push-action@v2
        with:
          context: .
          platforms: \${{ steps.generate.outputs.PLATFORM }}
          push: true
          tags: \${{ steps.generate.outputs.VERSION }}
          build-args: |
            TAG=\${{ steps.generate.outputs.TAG }}
            URL=\${{ steps.generate.outputs.URL }}
            CONFIG=\${{ steps.generate.outputs.CONFIG }}
            PHP8_SOCKETS_WORKAROUND=\${{ steps.generate.outputs.PHP8_SOCKETS_WORKAROUND }}
EOF
                else
                    current_platform="-${f}"
                    
                    if [[ ${f} = "php" ]]; then
                        current_platform=""
                    fi

                    current_os="-${o}"

                    if [[ ${o} = "debian" ]]; then
                        current_os=""
                    fi

                    echo -n ", ${1}-php${p}${current_platform}${current_os}"
                fi
            fi
        done
    done
done
