#!/usr/bin/env bash

set -ueo pipefail
IFS=$'\n\t'

new_version=$1
app_env=$2

git checkout $new_version
git tag -a -f "running_in_${app_env}" -m ""
git tag -a -f "deployed_to_${app_env}_$(date -u +"%Y-%m-%dT%H-%M")" -m "Deployed to ${app_env} by CD"
git push --tags
