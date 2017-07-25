#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

image=$1

docker_cache_dir=~/.dockercache

if [ -f $docker_cache_dir/$image/image.tar ]; then
  docker load -i $docker_cache_dir/$image/image.tar
else
  docker pull $image
  mkdir -p $docker_cache_dir/$image; docker save $image > $docker_cache_dir/$image/image.tar
fi
