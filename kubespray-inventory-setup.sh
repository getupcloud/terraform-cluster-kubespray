#!/bin/bash

if [ -z "$GIT_DIR" ]; then
  export GIT_DIR=$KUBESPRAY_DIR/.git
fi

export INVENTORY_DIR="$(dirname $INVENTORY_FILE)"
export GROUP_VARS_DIR="$INVENTORY_DIR/group_vars"
export MASTER_NODES_JSON="$(base64 -d <<<$MASTER_NODES)"
export INFRA_NODES_JSON="$(base64 -d <<<$INFRA_NODES)"
export APP_NODES_JSON="$(base64 -d <<<$APP_NODES)"
# inventory_builder vars
export CONFIG_FILE="$INVENTORY_FILE"
export KUBE_CONTROL_HOSTS=$(jq length <<<$MASTER_NODES_JSON)

set -eu

function create_inventory_file()
{
  if [ -e "$CONFIG_FILE" ]; then
    return
  fi

  local nodes=(
    $(jq -r '.[]|"\(.hostname),\(.address // empty)"' <<<${MASTER_NODES_JSON})
    $(jq -r '.[]|"\(.hostname),\(.address // empty)"' <<<${INFRA_NODES_JSON})
    $(jq -r '.[]|"\(.hostname),\(.address // empty)"' <<<${APP_NODES_JSON})
  )

  $KUBESPRAY_DIR/contrib/inventory_builder/inventory.py ${nodes[*]} >&2

  # add labels and taints
  for node in $(jq -r '.[]|.hostname' <<<${MASTER_NODES_JSON}); do
    #local labels=$(jq -r '.[]|select(hostname == "'$node'") | .labels')
    #if [ -n "$labels" ]
    #yq e -i '.all.hosts.*.node_labels.role="infra"' /cluster/hosts.yaml
    :
  done
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
