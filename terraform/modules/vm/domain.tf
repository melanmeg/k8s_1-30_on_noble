resource "libvirt_domain" "domain" {
  count      = var.vm_count
  arch       = "x86_64"
  autostart  = var.autostart
  memory     = var.memory
  name       = "${var.vm_name}-${count.index + 1}"
  qemu_agent = false
  running    = true
  type       = "kvm"
  vcpu       = var.vcpu

  cloudinit = libvirt_cloudinit_disk.commoninit[count.index].id

  cpu {
    mode = "host-passthrough"
  }

  console {
    target_port = "0"
    type        = "pty"
  }

  disk {
    scsi      = false # The controller model is set to virtio-scsi
    volume_id = libvirt_volume.volume[count.index].id
  }

  dynamic "disk" {
    for_each = var.data_disk.enable ? [1] : []
    content {
      scsi      = false
      volume_id = libvirt_volume.data-volume[count.index].id
    }
  }

  graphics {
    autoport    = "true"
    listen_type = "address"
    type        = "spice"
  }

  network_interface {
    bridge = "br0"
  }
}
