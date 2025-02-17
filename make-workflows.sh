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
php=("7.4" "8.2")
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
    runs-on: ubuntu-22.04
${needs}
    steps:
      - name: Checkout the repo
        uses: actions/checkout@v4
      - name: Set up QEMU
        uses: docker/setup-qemu-action@v3
        with:
          # setup-qemu-action by default uses 'tonistiigi/binfmt:latest' image,
          # which is out of date. This causes seg faults during build.
          # Here we manually fix the version.
          image: tonistiigi/binfmt:qemu-v7.0.0
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
      - name: Login to DockerHub
        uses: docker/login-action@v3
        with:
          username: \${{ secrets.DOCKERHUB_USERNAME }}
          password: \${{ secrets.DOCKERHUB_TOKEN }}
      - name: Generate Dockerfile
        id: generate
        run: |
          ./build.sh -g -v \${{ github.event.inputs.version }} -p ${p} -o ${o} ${f}
        env:
          dockerhub_username: \${{ secrets.DOCKERHUB_USERNAME }}
      - name: Build and push
        uses: docker/build-push-action@v6
        with:
          context: .
          platforms: \${{ steps.generate.outputs.PLATFORM }}
          push: true
          tags: \${{ steps.generate.outputs.VERSION }}
          build-args: |
            TAG=\${{ steps.generate.outputs.TAG }}
            URL=\${{ steps.generate.outputs.URL }}
            CONFIG=\${{ steps.generate.outputs.CONFIG }}
            PHP_EXTENSION=\${{ steps.generate.outputs.PHP_EXTENSION }}
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
