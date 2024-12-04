output base_volume_id {
  value       = libvirt_volume.base-volume.id
  sensitive   = false
}
output pool_name {
  value       = libvirt_pool.pool.name
  sensitive   = false
}
