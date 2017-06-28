#!/usr/bin/env bash

set -ueo pipefail
IFS=$'\n\t'

source $(dirname "$0")/get_version.sh

new_version=$1
app_env=$2

docker_image_versioned="registry.heroku.com/$DOCKER_REPO/$DOCKER_ARTIFACT:$new_version"
web_tag="registry.heroku.com/${app_env}-${DOCKER_REPO}/web"

docker login -u "$DOCKER_ID" -p "$DOCKER_PASSWORD" registry.heroku.com
docker pull "$docker_image_versioned"
docker tag "$docker_image_versioned" "$web_tag"
docker push "$web_tag"

git checkout $new_version
git tag -a -f "running_in_${app_env}" -m ""
git tag -a -f "deployed_to_${app_env}_$(date -u +"%Y-%m-%dT%H-%M")" -m "Deployed to ${app_env} by CD"
git push --tags
