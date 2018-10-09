#!/usr/bin/env bash

set -ueo pipefail
IFS=$'\n\t'

docker_image_versioned=${1:?"Pass the full docker image tag to be deployed as arg 1"}
app_env=${2:?"Pass the env to deploy to as arg 2"}
base_heroku_project=${3:?"Pass the base heroku project as arg 3"}
base_domain_name=${4:?"Pass the base domain name as arg 4"}
team_name=${5:?"Pass the heroku team name as arg 5"}

heroku_project="${app_env}-${base_heroku_project}"
new_env=false

: ${HEROKU_API_KEY:?"Need to set HEROKU_API_KEY env var to interact with heroku"}

if ! heroku apps:info "$heroku_project" >/dev/null 2>&1; then
  heroku apps:create "$heroku_project" --no-remote --region eu --team "$team_name"
  new_env=true
fi

heroku_docker_registry="registry.heroku.com"

echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_ID" --password-stdin "$heroku_docker_registry"

set +e
docker pull "$docker_image_versioned"
set -e

web_tag="${heroku_docker_registry}/${heroku_project}/web"
docker tag "$docker_image_versioned" "$web_tag"
docker push "$web_tag"
heroku container:release web -a "$heroku_project}"

if [ "$new_env" = true ] ; then
  heroku ps:scale web=1:Hobby -a "$heroku_project"
  heroku domains:add "${app_env}.${base_domain_name}" -a "$heroku_project"
fi
