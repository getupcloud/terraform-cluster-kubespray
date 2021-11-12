variable "masters" {
  description = "List of master nodes to provision"
  type        = list(any)
  default = [
    {
      address : "1.1.1.1",
      hostname : "master-0",
      ssh_private_key : "~/.ssh/id_rsa",

      disks : {
        etcd : {
          device : "/dev/sdb",
          mountpoint : "/var/lib/containers"
        },
        kubelet : {
          device : "/dev/sdc",
          mountpoint : "/var/lib/kubelet"
        }
        containers : {
          device : "/dev/sdd",
          mountpoint : "/var/lib/etcd"
        }
      }
    }
  ]
}

variable "workers" {
  description = "List of worker nodes to provision"
  type        = list(any)
  default = [
    {
      address : "2.2.2.2",
      hostname : "infra-0"

      disks : {
        kubelet : {
          device : "/dev/sdb",
          mountpoint : "/var/lib/kubelet",
        }
        containers : {
          device : "/dev/sdc",
          mountpoint : "/var/lib/containers",
        }
      }
    },
    {
      address : "3.3.3.3",
      hostname : "app-0",

      disks : {
        kubelet : {
          device : "/dev/sdb",
          mountpoint : "/var/lib/kubelet",
        }
        containers : {
          device : "/dev/sdc",
          mountpoint : "/var/lib/containers",
        }
      }
    }
  ]
}

variable "ssh_user" {
  description = "SSH username"
  type        = string
}

variable "ssh_password" {
  description = "SSH password"
  type        = string
  default     = null
}

variable "ssh_private_key" {
  description = "Path for SSH private key"
  type        = string
  default     = "~/.ssh/id_rsa"
}

variable "ssh_bastion_host" {
  description = "SSH password"
  type        = string
  default     = null
}

variable "ssh_bastion_user" {
  description = "SSH bastion username"
  type        = string
  default     = null
}

variable "ssh_bastion_password" {
  description = "SSH bastion password"
  type        = string
  default     = null
}

variable "ssh_bastion_private_key" {
  description = "Path for SSH bastion private key"
  type        = string
  default     = "~/.ssh/id_rsa"
}

variable "custom_provisioner" {
  description = "Path for custom provisioner script"
  type        = string
  default     = null
}

variable "install_packages" {
  description = "Packages to install on nodes"
  type        = list(string)
  default = [
    "chrony",
    "conntrack-tools",
    "git",
    "iproute-tc",
    "jq",
    "moreutils",
    "netcat",
    "NetworkManager",
    "python3-openshift",
    "python3-passlib",
    "python3-pip",
    "python3-pyOpenSSL",
    "python3-virtualenv",
    "strace",
    "tcpdump"
  ]
}

variable "uninstall_packages" {
  description = "Packages to install on nodes"
  type        = list(string)
  default = [
    "firewalld",
    "ntpd"
  ]
}