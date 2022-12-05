#!/bin/bash

if [ -z "$KUBESPRAY_REPO_DIR" ]; then
  echo Missing var KUBESPRAY_REPO_DIR
  exit 1
fi

export GIT_DIR=$KUBESPRAY_REPO_DIR/.git

set -eu

function validate_parameters()
{
  if [[ "${KUBESPRAY_GIT_REF}" =~ ^refs/(heads|tags)/.* ]]; then
    return 0
  elif [[ "${KUBESPRAY_GIT_REF}" =~ ^remotes/origin/.* ]]; then
    return 0
  fi

  echo "Invalid git ref: $KUBESPRAY_GIT_REF. Accepted format: refs/{heads|tags}/{name}"
  exit 1
}

function command_create()
{
  validate_parameters

  if [ -e "$KUBESPRAY_DIR" ]; then
    rm -rf "$KUBESPRAY_DIR"
  fi

  ln -fs $KUBESPRAY_REPO_DIR $KUBESPRAY_DIR

  git checkout "$KUBESPRAY_GIT_REF" >&2
  pip3 install --user -r $KUBESPRAY_REPO_DIR/requirements.txt >&2
  command_read
}

function command_update()
{
  validate_parameters
  command_create
}

function command_read()
{
  {
    git_hash=$(git log -1 --pretty=format:%h)
    git_ref="$(git rev-parse --symbolic-full-name $KUBESPRAY_GIT_REF)"
    requirements_txt_id=$(md5sum $KUBESPRAY_REPO_DIR/requirements.txt | awk '{print $1}')
  } >&2

  kubespray_link=""
  if [ -e "$KUBESPRAY_DIR" ]; then
    kubespray_link="$KUBESPRAY_DIR"
  fi

  jq -Mcn \
    --arg git_hash $git_hash \
    --arg git_ref $git_ref \
    --arg requirements_txt_id $requirements_txt_id \
    --arg kubespray_link $kubespray_link \
    '{
        "git_hash": $git_hash,
        "git_ref": $git_ref,
        "requirements_txt_id": $requirements_txt_id,
        "kubespray_repo": $kubespray_link
    }'
}

function command_delete()
{
  echo {}
}

eval command_$1
