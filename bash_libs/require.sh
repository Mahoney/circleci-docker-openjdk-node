#!/usr/bin/env bash

function require {
  local theCommand=$1
  local instructions=${2:-""}
  command -v $theCommand >/dev/null 2>&1 || { echo >&2 "I require $theCommand but it's not installed.  Aborting."; echo >&2 "$instructions"; exit 1; }
}
