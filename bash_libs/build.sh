#!/usr/bin/env bash

set -ueo pipefail
IFS=$'\n\t'

docker build -t "$DOCKER_REPO/$DOCKER_ARTIFACT:latest" .
