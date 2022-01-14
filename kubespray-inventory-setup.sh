#!/bin/bash

if [ -z "$GIT_DIR" ]; then
  export GIT_DIR=$KUBESPRAY_DIR/.git
fi

export INVENTORY_DIR="$(dirname $INVENTORY_FILE)"
export GROUP_VARS_DIR="$INVENTORY_DIR/group_vars"
export MASTERS_JSON="$(base64 -d <<<$MASTERS)"
export WORKERS_JSON="$(base64 -d <<<$WORKERS)"
# inventory_builder vars
export CONFIG_FILE="$INVENTORY_FILE"
export KUBE_CONTROL_HOSTS=$(jq length <<<$MASTERS_JSON)

set -eu

function create_inventory_file()
{
  if [ -e "$CONFIG_FILE" ]; then
    return
  fi

  local nodes=(
    $(jq '.[]|"\(.hostname) ansible_host=\(.address // empty)"' <<<${MASTERS_JSON})
    $(jq '.[]|"\(.hostname) ansible_host=\(.address // empty)"' <<<${WORKERS_JSON})
  )

  $KUBESPRAY_DIR/contrib/inventory_builder/inventory.py ${nodes[*]} >&2
}

function copy_group_vars()
{
  if [ -d "$GROUP_VARS_DIR" ]; then
    return
  fi

  cp -var $KUBESPRAY_DIR/inventory/sample/group_vars $GROUP_VARS_DIR
}

function command_create()
{
  create_inventory_file
  copy_group_vars
}

function command_update()
{
  command_create
}

function command_read()
{
  local inventory_hash=""
  local group_vars_dir=""

  if [ -e "$INVENTORY_FILE" ]; then
    inventory_hash=$(md5sum $INVENTORY_FILE | awk '{print $1}')
  fi

  if [ -d $GROUP_VARS_DIR ]; then
    group_vars_dir=$GROUP_VARS_DIR
  fi

  jq -Mcn \
    --arg i $inventory_hash \
    --arg g $group_vars_dir \
    '{"inventory_hash": $i, "group_vars_dir": $g}'
}

function command_delete()
{
  echo {}
}

eval command_$1
