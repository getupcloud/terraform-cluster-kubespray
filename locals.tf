locals {
  kubeconfig = abspath(pathexpand(var.kubeconfig_filename))
  suffix     = random_string.suffix.result
  secret     = random_string.secret.result

  git_setup = <<EOF
    {
      if [ -d ${var.kubespray_dir} ]; then
        cd ${var.kubespray_dir}
        git fetch origin
      else
        git clone ${path.module}/kubespray ${var.kubespray_dir}
        cd ${var.kubespray_dir}
      fi

      branch=$(git rev-parse --abbrev-ref HEAD)

      if [ "$branch" != "$KUBESPRAY_GIT_REF" ]; then
        git checkout -b "$KUBESPRAY_GIT_REF" "$KUBESPRAY_GIT_REF"
      fi

      branch=$(git rev-parse --abbrev-ref HEAD)
      hash=$(git log -1 --pretty=format:%h)
    } >&2

    pip3 install --user -r requirements.txt >&2

    echo "{
      \"hash\": \"$hash\",
      \"ref\": \"$KUBESPRAY_GIT_REF\",
      \"branch\": \"$branch\"
    }"
  EOF

  git_state = <<EOF
    {
      cd ${path.module}/kubespray
      hash=$(git log -1 --pretty=format:%h)
      branch=$(git rev-parse --abbrev-ref HEAD)
    } >&2

    echo "{
      \"hash\": \"$hash\",
      \"ref\": \"$KUBESPRAY_GIT_REF\",
      \"branch\": \"$branch\"
    }"
  EOF

  git_reset = <<EOF
    {
      cd ${path.module}/kubespray
      git switch -c master
      git reset --hard
    } >&2
    echo {}
  EOF
}
