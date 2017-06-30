#!/usr/bin/env bash

set -ueo pipefail
IFS=$'\n\t'

source $(dirname "$0")/get_version.sh

new_version=$(get_version)

git tag -a "$new_version" -m "Release version $new_version"  > /dev/null
git push origin "$new_version" > /dev/null
echo "$new_version"
