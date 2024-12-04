resource "libvirt_cloudinit_disk" "commoninit" {
  count          = var.vm_count
  name           = "${format("%s-%02d.iso", var.vm_name, count.index + 1)}"
  pool           = var.pool_name

  meta_data = <<EOF
    local-hostname: ${var.vm_name}-${count.index + 1}
    EOF

  user_data = <<EOF
    #cloud-config
    users:
      - default
      - name: melanmeg
        shell: /bin/bash
        sudo: ALL=(ALL) NOPASSWD:ALL
        groups: sudo
        chpasswd:
          expire: False
        lock_passwd: false
        ssh_import_id: gh:melanmeg
        passwd: \$6\$rounds=4096\$iLPqVWPhF9FMY3Le\$7ukCEP1NijC5n7/D/jccsOf5fnrPyuk03sI9A8uhHjhmiwu7tkbT7c80fTd6X5cbbM.itwCnj7tUGHT9rk6LO0
    timezone: Asia/Tokyo
    runcmd:
      - sed -i.bak -r 's!http://(security|archive|[a-z]{2}\.archive).ubuntu.com/ubuntu!http://ftp.riken.go.jp/Linux/ubuntu!' /etc/apt/sources.list.d/ubuntu.sources
      - apt upgrade -yU
      - apt purge -y needrestart
      - echo "set bell-style none" | tee -a /etc/inputrc # Suppress beep sound
      - chmod -x /etc/update-motd.d/* # Suppress login Log
      - sed -i 's/^#PrintLastLog yes/PrintLastLog no/' /etc/ssh/sshd_config # Suppress last Log
      - nc -l -p 12345
    EOF

  network_config = <<EOF
    version: 2
    ethernets:
      ens3:
        dhcp4: false
        dhcp6: false
        addresses: [${cidrhost("192.168.11.0/24", split(".", var.first_ip)[3] + count.index)}/24]
        gateway4: 192.168.11.1
        nameservers:
          addresses: [192.168.11.1]
    EOF
}
