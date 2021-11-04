locals {
  kubeconfig = abspath(pathexpand(var.kubeconfig_filename))
  suffix     = random_string.suffix.result
  secret     = random_string.secret.result

  git_checkout = <<EOF
    {
      cd ${path.module}/kubespray
      git checkout -b "$KUBESPRAY_GIT_REF" "$KUBESPRAY_GIT_REF"
      hash=$(git log -1 --pretty=format:%h)
      branch=$(git rev-parse --abbrev-ref HEAD)
    } >/dev/null
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
    } >/dev/null
    echo "{
      \"hash\": \"$hash\",
      \"ref\": \"$KUBESPRAY_GIT_REF\",
      \"branch\": \"$branch\"
    }"
  EOF

  git_reset = <<EOF
    cd ${path.module}/kubespray
    git switch -c master
    git reset --hard
    echo {}
  EOF
}
