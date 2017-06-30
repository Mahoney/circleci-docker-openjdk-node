#!/usr/bin/env bash

set -ueo pipefail
IFS=$'\n\t'

docker_image_versioned=$1
app_env=$2

heroku_docker_registry="registry.heroku.com"

docker login -u "$DOCKER_ID" -p "$DOCKER_PASSWORD" "$heroku_docker_registry"

docker pull "$docker_image_versioned"

web_tag="${heroku_docker_registry}/${app_env}-${DOCKER_REPO}/web"
docker tag "$docker_image_versioned" "$web_tag"
docker push "$web_tag"
