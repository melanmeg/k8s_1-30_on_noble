resource "libvirt_pool" "pool" {
  name = "terraform-pool"
  type = "dir"
  target {
    path = var.pool_path
  }
}

resource "libvirt_volume" "base-volume" {
  format = "qcow2"
  name   = "base.qcow2"
  pool   = libvirt_pool.pool.name
  source = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
}
