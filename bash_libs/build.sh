#!/usr/bin/env bash

set -ueo pipefail
IFS=$'\n\t'

source $(dirname "$0")/docker.sh
docker_image=$1

docker build -t "$docker_image:latest" .
