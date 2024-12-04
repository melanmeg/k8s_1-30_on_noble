resource "libvirt_volume" "volume" {
  count           = var.vm_count
  format          = "qcow2"
  name            = "${format("%s-%02d.qcow2", var.vm_name, count.index + 1)}"
  pool            = var.pool_name
  size            = var.size * 1024 * 1024 * 1024 # Convert to GiB
  base_volume_id  = var.base_volume_id
}

resource "libvirt_volume" "data-volume" {
  count           = var.vm_count
  format          = "raw"
  name            = "${format("%s-data-%02d.qcow2", var.vm_name, count.index + 1)}"
  pool            = var.pool_name
  size            = var.data_disk.size * 1024 * 1024 * 1024 # Convert to GiB
}
