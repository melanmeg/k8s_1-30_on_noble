variable vm_count {
  type = number
}
variable vm_name {
  type = string
}
variable vcpu {
  type = number
}
variable memory {
  type = number
}
variable size {
  type = number
}
variable "data_disk" {
  type = object({
    enable = bool
    size   = number
  })
  default = {
    enable = false
    size   = 10
  }
}
variable autostart {
  type = bool
}
variable first_ip {
  type = string
}
variable ssh_ip {
  type = string
}
variable keyfile {
  type = string
}
variable base_volume_id {
  type = string
}
variable pool_name {
  type = string
}
