#!/usr/bin/env bash

set -ueo pipefail
IFS=$'\n\t'

source $(dirname "$0")/get-version.sh

new_version=$(get_version)

git tag -a "$new_version" -m "Release version $new_version"  >/dev/null 2>&1
git push origin "$new_version" >/dev/null 2>&1
echo -n "$new_version"
