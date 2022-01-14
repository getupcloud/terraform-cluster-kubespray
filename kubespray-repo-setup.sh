#!/bin/bash

if [ -z "$GIT_DIR" ]; then
  export GIT_DIR=$KUBESPRAY_DIR/.git
fi

set -eu

function command_create()
{
  {
    if ! [ -d $KUBESPRAY_DIR ]; then
      git clone $KUBESPRAY_GIT_REPO $KUBESPRAY_DIR
    fi

    branch=$(git rev-parse --abbrev-ref HEAD | sed -e 's|^heads/||')

    if [ "$branch" != "$KUBESPRAY_GIT_REF" ]; then
      git switch -c "$KUBESPRAY_GIT_REF" || git switch "$KUBESPRAY_GIT_REF"
    fi

    branch=$(git rev-parse --abbrev-ref HEAD | sed -e 's|^heads/||')
    hash=$(git log -1 --pretty=format:%h)

  } >&2

  if [ "$branch" != "$KUBESPRAY_GIT_REF" ]; then
    echo "Invalid kubespray git ref: $KUBESPRAY_GIT_REF"
    exit 1
  fi

  pip3 install --user -r $KUBESPRAY_DIR/requirements.txt >&2

  command_read
}

function command_update()
{
  command_create
  command_read
}

function command_read()
{
  {
    hash=$(git log -1 --pretty=format:%h)
    branch=$(git rev-parse --abbrev-ref HEAD | sed -e 's|^heads/||')
  } >&2

  jq -Mcn \
    --arg h $hash \
    --arg r $KUBESPRAY_GIT_REF \
    --arg b $branch \
    '{"hash": $h, "ref": $r, "branch": $b}'
}

function command_delete()
{
  {
    git switch master || git switch main
    git reset --hard
  } >&2

  echo {}
}

eval command_$1
