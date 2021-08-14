#!/bin/bash

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

php=("7.3" "7.4" "8.0")
platform=("php" "cli" "fpm" "apache")

for p in ${php[@]}
do
    for f in ${platform[@]}
    do
        id="build_${p//./}_${f}"
        cat <<EOF
  ${id}:
    concurrency: ${id}
    runs-on: ubuntu-latest
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
          ./build.sh -g -v \${{ github.event.inputs.version }} -p ${p} ${f}
      - name: Build and push
        uses: docker/build-push-action@v2
        with:
          context: .
          platforms: \${{ steps.generate.outputs.PLATFORM }}
          push: true
          tags: \${{ steps.generate.outputs.VERSION }}
          build-args: TAG=\${{ steps.generate.outputs.TAG }},URL=\${{ steps.generate.outputs.URL }},VERSION=\${{ steps.generate.outputs.VERSION }}
EOF
    done
done
