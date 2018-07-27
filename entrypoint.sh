#!/usr/bin/env bash
set -ueo pipefail
IFS=$'\n\t'

group_ids_to_add=()

function parseNameId {
  local input=$1

  echo "$input" | tr '(' '\n' | cut -d')' -f1
}

function addGroup {
  local id=$1
  local name=$2
  local name_without_spaces=$(echo "$name" | tr " " "_")

  set +e
  groupadd -o -g "$id" "$name_without_spaces" >/dev/null 2>&1
  result=$?
  set -e
  if [[ ("$result" == 0) ]]; then
    group_ids+=("$id")
  elif [[ ("$result" == 9) ]]; then
    local actual_id=$(getent group $name | cut -d':' -f3)
    group_ids+=("$actual_id")
    addGroup "$id" "${name_without_spaces}__$RANDOM"
  fi
}

function addUser {
  local id=$1
  local name=$2
  local group_id=$3
  local group_name=$4
  local all_groups=$5

  if id -u $name >/dev/null 2>&1; then
    usermod -G ${all_groups} $name
  else
    useradd -M -g $group_id -u "$id" -G $all_groups $name
    if [ ! -e "/home/$name" ]; then
      mkdir -p "/home/$name"
    fi
    if [ -d "/home/$name" ]; then
      chown "$name" "/home/$name"
      chgrp "$group_id" "/home/$name"
      chmod 755 "/home/$name"
    fi
  fi
}

function getField {
  local data=$1
  local fieldName=$2

  local idNamePattern="[0-9]+\([^)]+\)"
  local regex="$fieldName=($idNamePattern(,$idNamePattern)*)"

  if [[ ${data} =~ $regex ]]; then
    echo "${BASH_REMATCH[1]}"
  else
    return 1
  fi
}

function join_by {
  local IFS="$1"
  shift
  echo "$*"
}

if [ -n "${ID_DATA:-}" ]; then
    user_data=$(getField "$ID_DATA" "uid")
    group_data=$(getField "$ID_DATA" "gid")
    groups_data=$(getField "$ID_DATA" "groups")

    groups=$(echo $groups_data | tr ',', '\n')
    for group in ${groups}; do
      addGroup $(parseNameId "$group")
    done

    parsedGroupData=$(parseNameId "$group_data")
    parsedUserData=$(parseNameId "$user_data")

    joinedGroupIds=$(join_by , ${group_ids[@]})
    currentUserGroupIds=$(id -G)
    currentUserGroupIdsJoined=$(join_by , ${currentUserGroupIds[@]})
    allGroupsToJoin=$(join_by , $joinedGroupIds $currentUserGroupIds)
    addUser ${parsedUserData} ${parsedGroupData} "$allGroupsToJoin"

    username=$(echo $parsedUserData | cut -d' ' -f2)

    su $username bash -c "$*"
else
  $@
fi
