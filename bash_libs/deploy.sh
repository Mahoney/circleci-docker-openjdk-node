#!/usr/bin/env bash

set -ueo pipefail
IFS=$'\n\t'

source $(dirname "$0")/get_version.sh

new_version=$(get_version)

docker_image="$DOCKER_REPO/$DOCKER_ARTIFACT"
docker_image_latest="$docker_image:latest"
docker_image_versioned="$docker_image:$new_version"

git tag -a "$new_version" -m "Release version $new_version"

docker tag "$docker_image_latest" "$docker_image_versioned"
docker login -u "$DOCKER_ID" -p "$DOCKER_PASSWORD" "${DOCKER_REGISTRY:-registry.hub.docker.com}"
docker push "$docker_image_latest"
docker push "$docker_image_versioned"
git push origin "$new_version"
