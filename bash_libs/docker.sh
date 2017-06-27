#!/usr/bin/env bash

function calc_docker_image {

  local docker_registry=${DOCKER_REGISTRY:-""}

  if [ -z "$docker_registry" ]; then
    echo "$DOCKER_REPO/$DOCKER_ARTIFACT"
  else
    echo "$docker_registry/$DOCKER_REPO/$DOCKER_ARTIFACT"
  fi
}
