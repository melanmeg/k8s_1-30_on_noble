locals {
  ssh_ip  = "192.168.11.12"
  keyfile = "~/.ssh/main"
}

module k8s-common-libvirt {
  source = "../modules/common"

  pool_path = "/var/kvm/terraform/images"
  ssh_ip  = local.ssh_ip
  keyfile = local.keyfile
}

module k8s-lb-libvirt {
  source = "../modules/vm"

  vm_count  = 2
  vm_name   = "test-k8s-lb" # $VM_NAME-$VM_COUNT
  vcpu      = 1
  memory    = 3072
  size      = 40 # GiB
  autostart = false
  first_ip  = "192.168.11.131" # $FIRST_IP + $VM_COUNT

  base_volume_id = module.k8s-common-libvirt.base_volume_id
  pool_name      = module.k8s-common-libvirt.pool_name
  ssh_ip         = local.ssh_ip
  keyfile        = local.keyfile
}

module k8s-cp-libvirt {
  source = "../modules/vm"

  vm_count  = 3
  vm_name   = "test-k8s-cp" # $VM_NAME-$VM_COUNT
  vcpu      = 2
  memory    = 4096
  size      = 40 # GiB
  autostart = false
  first_ip  = "192.168.11.141" # $FIRST_IP + $VM_COUNT

  base_volume_id = module.k8s-common-libvirt.base_volume_id
  pool_name      = module.k8s-common-libvirt.pool_name
  ssh_ip         = local.ssh_ip
  keyfile        = local.keyfile
}

module k8s-wk-libvirt {
  source = "../modules/vm"

  vm_count  = 3
  vm_name   = "test-k8s-wk" # $VM_NAME-$VM_COUNT
  vcpu      = 3
  memory    = 4096
  size      = 40 # GiB
  data_disk = {
    enable  = true
    size    = 20 # GiB
  }
  autostart = false
  first_ip  = "192.168.11.151" # $FIRST_IP + $VM_COUNT

  base_volume_id = module.k8s-common-libvirt.base_volume_id
  pool_name      = module.k8s-common-libvirt.pool_name
  ssh_ip         = local.ssh_ip
  keyfile        = local.keyfile
}
