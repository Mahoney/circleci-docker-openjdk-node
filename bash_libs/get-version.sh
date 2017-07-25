#!/usr/bin/env bash

source $(dirname "$0")/require.sh

function get_version() {

  require semver "To fix: npm install --global semver"

  git fetch --tags >/dev/null 2>&1

  local all_tags=$(git tag -l)
  if [ -z "$all_tags" ]; then
    echo "1.0.0"
  else
    set +e
    local latest_version=$(semver $all_tags | tail -n1)
    set -e
    if [ -z "$latest_version" ]; then
      echo "1.0.0"
    else
      semver -i minor $latest_version
    fi
  fi
}
