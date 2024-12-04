resource "null_resource" "run_shell" {
  count = var.vm_count
  provisioner "local-exec" {
    command = <<EOF
      echo "Waiting for runcmd to start..."
      while true; do
        if ! nc -z -w5 "${cidrhost("192.168.11.0/24", split(".", var.first_ip)[3] + count.index)}" 12345 > /dev/null 2>&1; then
          echo "Waiting per 5s for runcmd on ${cidrhost("192.168.11.0/24", split(".", var.first_ip)[3] + count.index)}:12345..."
        else
          echo "\e[1;36m Health Check Done: ${cidrhost("192.168.11.0/24", split(".", var.first_ip)[3] + count.index)}! \e[m"
          break
        fi
        sleep 5
      done
     EOF
  }
  depends_on = [libvirt_domain.domain]
}
