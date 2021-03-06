#!/usr/bin/env bash

set -ueo pipefail
IFS=$'\n\t'

source $(dirname "$0")/docker.sh

docker_image_to_deploy=$1
new_version=$2

docker_image=$(calc_docker_image)
docker_image_versioned="$docker_image:$new_version"

docker tag "$docker_image_to_deploy" "$docker_image_versioned"
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_ID" --password-stdin ${DOCKER_REGISTRY:-""}
docker push "$docker_image_versioned"
echo -n "$docker_image_versioned"
