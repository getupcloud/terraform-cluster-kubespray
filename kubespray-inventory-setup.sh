#!/bin/bash

if [ -z "$GIT_DIR" ]; then
  export GIT_DIR=$KUBESPRAY_DIR/.git
fi

export INVENTORY_DIR="$(dirname $INVENTORY_FILE)"
export GROUP_VARS_DIR="$INVENTORY_DIR/group_vars"
export KUBE_VERSION="$(base64 -d <<<$KUBE_VERSION)"
export MASTER_NODES_JSON="$(base64 -d <<<$MASTER_NODES)"
export INFRA_NODES_JSON="$(base64 -d <<<$INFRA_NODES)"
export APP_NODES_JSON="$(base64 -d <<<$APP_NODES)"
# inventory_builder vars
export CONFIG_FILE="$INVENTORY_FILE"
export KUBE_CONTROL_HOSTS=$(jq length <<<$MASTER_NODES_JSON)

set -eu

function create_inventory_file()
{
  #if [ -e "$CONFIG_FILE" ]; then
  #  return
  #fi

  local nodes=(
    $(jq -r '.[]|"\(.hostname),\(.address // empty)"' <<<${MASTER_NODES_JSON})
    $(jq -r '.[]|"\(.hostname),\(.address // empty)"' <<<${INFRA_NODES_JSON})
    $(jq -r '.[]|"\(.hostname),\(.address // empty)"' <<<${APP_NODES_JSON})
  )

  if [ -e $KUBESPRAY_DIR/contrib/inventory_builder/inventory.py ]; then
    python3 $KUBESPRAY_DIR/contrib/inventory_builder/inventory.py ${nodes[*]} >&2
  elif which inventory-builder.py 7>/dev/null; then
    inventory-builder.py ${nodes[*]} >&2
  fi

  # add labels and taints
  printenv MASTER_NODES_JSON INFRA_NODES_JSON APP_NODES_JSON \
  | jq -s '.[] | .[] | {(.hostname // .address):{node_taints: .node_taints, node_labels: .node_labels}}' \
  | jq -s add \
  | jq '{all:{hosts:.,vars:{kube_version:"'$KUBE_VERSION'"}}}' \
  | yq e -P - \
  > /tmp/hosts-patch.yaml

  yq eval-all 'select(fileIndex==0) * select(fileIndex==1)' $INVENTORY_FILE /tmp/hosts-patch.yaml > $INVENTORY_FILE.tmp
  yq -i e '.all.children.etcd.hosts = .all.children.kube_control_plane.hosts' $INVENTORY_FILE.tmp
  mv -f $INVENTORY_FILE.tmp $INVENTORY_FILE
}

function copy_group_vars()
{
  cp -avnr $KUBESPRAY_DIR/inventory/sample/group_vars/* $GROUP_VARS_DIR
}

function update_group_vars()
{
  sed -i.bkp -e "s/^kube_version:.*/# kube_version: $KUBE_VERSION # Commented by terraform.tfvars. It now comes from hosts.yaml/" $GROUP_VARS_DIR/k8s_cluster/k8s-cluster.yml
  sed -i.bkp -e "s|^kube_vip_arp_enabled:\(.*\)|# kube_vip_arp_enabled:\1 # Commented by terraform.tfvars. It now comes from group_vars/all/getup.yml|" $GROUP_VARS_DIR/k8s_cluster/addons.yml
}

function command_create()
{
  create_inventory_file
  copy_group_vars
  update_group_vars
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
    --arg i "$inventory_hash" \
    --arg g "$group_vars_dir" \
    '{"inventory_hash": $i, "group_vars_dir": $g}'
}

function command_delete()
{
  echo {}
}

eval command_$1
