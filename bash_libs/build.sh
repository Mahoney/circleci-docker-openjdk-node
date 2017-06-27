#!/usr/bin/env bash

set -ueo pipefail
IFS=$'\n\t'

source $(dirname "$0")/docker.sh
docker_image=$(calc_docker_image)

docker build -t "$docker_image:latest" .
