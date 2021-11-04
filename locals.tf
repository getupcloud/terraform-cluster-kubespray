locals {
  kubeconfig = abspath(pathexpand(var.kubeconfig_filename))
  suffix     = random_string.suffix.result
  secret     = random_string.secret.result

#  git_clone  = <<EOF
#    if ! [ -d kubespray ]; then
#      git clone --recurse-submodules $GIT_REPO $GIT_WORK_TREE
#    fi
#    cd $GIT_WORK_TREE
#    git checkout -b $GIT_BRANCH
#  EOF
}
