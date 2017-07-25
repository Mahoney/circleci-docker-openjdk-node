#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

docker_cache_dir=~/.dockercache

for image in "$@"; do
  if [ -f $docker_cache_dir/$image/image.tar ]; then
    docker load -i $docker_cache_dir/$image/image.tar
  else
    docker pull $image
    mkdir -p $docker_cache_dir/$image
    docker save $image > $docker_cache_dir/$image/image.tar
  fi
done
