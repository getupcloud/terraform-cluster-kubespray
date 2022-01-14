locals {
  kubeconfig = abspath(pathexpand(var.kubeconfig_filename))
  suffix     = random_string.suffix.result
  secret     = random_string.secret.result

  git_setup = <<EOF
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

    pip3 install --user -r $KUBESPRAY_DIR/kubespray/requirements.txt >&2

    echo "{
      \"hash\": \"$hash\",
      \"ref\": \"$KUBESPRAY_GIT_REF\",
      \"branch\": \"$branch\"
    }"
  EOF

  git_state = <<EOF
    {
      hash=$(git log -1 --pretty=format:%h)
      branch=$(git rev-parse --abbrev-ref HEAD | sed -e 's|^heads/||')
    } >&2

    echo "{
      \"hash\": \"$hash\",
      \"ref\": \"$KUBESPRAY_GIT_REF\",
      \"branch\": \"$branch\"
    }"
  EOF

  git_reset = <<EOF
    {
      git switch master || git switch main
      git reset --hard
    } >&2
    echo {}
  EOF
}
