#!/usr/bin/env bash

set -ueo pipefail
IFS=$'\n\t'

docker_image_versioned=$1
app_env=$2
base_heroku_project=$3
base_domain_name=$4

heroku_project="${app_env}-${base_heroku_project}"
new_env=false

: ${HEROKU_API_KEY:?"Need to set HEROKU_API_KEY env var to interact with heroku"}

if ! heroku apps:info "$heroku_project" > /dev/null 2>&1; then
  heroku apps:create "$heroku_project" --region eu
  new_env=true
fi

heroku_docker_registry="registry.heroku.com"

docker login -u "$DOCKER_ID" -p "$DOCKER_PASSWORD" "$heroku_docker_registry"

docker pull "$docker_image_versioned"

web_tag="${heroku_docker_registry}/${heroku_project}/web"
docker tag "$docker_image_versioned" "$web_tag"
docker push "$web_tag"

if [ "$new_env" = true ] ; then
  heroku ps:scale web=1:Hobby -a "$heroku_project"
  heroku domains:add "${app_env}.${base_domain_name}" -a "$heroku_project"
fi
