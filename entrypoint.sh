#!/usr/bin/env bash
set -ueo pipefail

group_ids_to_add=()

function valueOf {
  echo "$1" | cut -d'=' -f2
}

function parseNameId {
  local input=$1

  echo "$input" | tr '(' '\n' | cut -d')' -f1
}

function addGroup {
  local id=$1
  local name=$2

  set +e
  sudo groupadd -o -g "$id" "$name" > /dev/null 2>&1
  result=$?
  set -e
  if [[ ("$result" == 0) ]]; then
    group_ids+=("$id")
  elif [[ ("$result" == 9) ]]; then
    local actual_id=$(getent group $name | cut -d':' -f3)
    group_ids+=("$actual_id")
    addGroup "$id" "${name}__$RANDOM"
  fi
}

function addUser {
  local id=$1
  local name=$2
  local group_id=$3
  local group_name=$4
  local other_groups=${@:5}

  set +e
    sudo useradd -g $group_id -u "$id" -G $other_groups $name
  set -e
}

function getField {
  local data=$1
  local index=$2

  valueOf $(echo "$1" | cut -d' ' -f$index)
}

function join_by {
  local IFS="$1"
  shift
  echo "$*"
}

if [ -n "${ID_DATA:-}" ]; then
    user_data=$(getField "$ID_DATA" 1)
    group_data=$(getField "$ID_DATA" 2)
    groups_data=$(getField "$ID_DATA" 3)

    groups=$(echo $groups_data | tr ',', '\n')
    for group in $groups; do
      addGroup $(parseNameId "$group")
    done

    parsedGroupData=$(parseNameId "$group_data")
    parsedUserData=$(parseNameId "$user_data")

    joinedGroupIds=$(join_by , ${group_ids[@]})
    currentUserGroupIds=$(id -G)
    currentUserGroupIdsJoined=$(join_by , ${currentUserGroupIds[@]})
    addUser $parsedUserData $parsedGroupData "$joinedGroupIds,$currentUserGroupIds"

    username=$(echo $parsedUserData | cut -d' ' -f2)

    sudo -u $username bash -c "$*"
else
  $@
fi