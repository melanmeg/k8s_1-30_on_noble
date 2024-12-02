#!/bin/bash

set -euo pipefail

cd "$(dirname "$0")"

echo -e "\e[1;36m Starting k8sa.sh... \e[m"

# region : set variables

IMAGE_SIZE=40G
IMAGE_PATH=/var/kvm/images
OS_VARIANT=ubuntu24.04

VM_LIST=(
    #vmid #vmname        #cpu #mem  #vmsrvip
    "1100 test-k8s-lb-1  1    3072  192.168.11.131"
    "1110 test-k8s-lb-2  1    3072  192.168.11.132"
    "1114 test-k8s-cp-1  2    4096  192.168.11.141"
    "1115 test-k8s-cp-2  2    4096  192.168.11.142"
    "1116 test-k8s-cp-3  2    4096  192.168.11.143"
    "1124 test-k8s-wk-1  2    4096  192.168.11.151"
    "1125 test-k8s-wk-2  2    4096  192.168.11.152"
    "1126 test-k8s-wk-3  2    4096  192.168.11.153"
)

# endregion

# ---

# region : create template

# download the image(ubuntu 24.04 LTS)
wget https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img

# resize the downloaded disk
qemu-img resize image.img ${IMAGE_SIZE}

# endregion

# ---

# region : preparation

for array in "${VM_LIST[@]}"
do
    echo "${array}" | while read -r vmid vmname cpu mem vmsrvip
    do
        # move the image and rename the vm name
        sudo cp image.img "${IMAGE_PATH}/${vmname}.img"

        # owner setting
        sudo chown libvirt-qemu:kvm "${IMAGE_PATH}/${vmname}.img"

        # create snippet for cloud-init(meta-data)
        # START irregular indent because heredoc
# ----- #
cat > meta-data.yaml <<EOF
instance-id: ${vmid}
local-hostname: ${vmname}
EOF
# ----- #
        # END irregular indent because heredoc

        # create snippet for cloud-init(user-data)
        # START irregular indent because heredoc
# ----- #
cat > user-data.yaml <<EOF
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
# ----- #
        # END irregular indent because heredoc

        # create snippet for cloud-init(network-config)
        # START irregular indent because heredoc
# ----- #
cat > network-config.yaml << EOF
version: 2
ethernets:
  enp1s0:
    dhcp4: false
    dhcp6: false
    addresses: [${vmsrvip}/24]
    gateway4: 192.168.11.1
    nameservers:
      addresses: [192.168.11.1]
EOF
# ----- #
        # END irregular indent because heredoc

        # create Cloud-Init CD-ROM drive
        sudo cloud-localds seed.img user-data.yaml meta-data.yaml -N network-config.yaml

        # move the seed image and rename
        sudo mv seed.img "${IMAGE_PATH}/seed${vmid}.img"

        # owner setting
        sudo chown libvirt-qemu:kvm "${IMAGE_PATH}/seed${vmid}.img"

        # cleanup
        rm -f meta-data.yaml
        rm -f user-data.yaml
        rm -f network-config.yaml

# endregion

# ---

# region : setup vm on kvm

        # create vm
        # START irregular indent because heredoc
# ----- #
sudo virt-install \
  --name "${vmname}" \
  --vcpus "${cpu}" --memory "${mem}" \
  --network bridge=br0 \
  --disk "${IMAGE_PATH}/${vmname}.img,device=disk,bus=virtio,format=qcow2" \
  --disk "${IMAGE_PATH}/seed${vmid}.img,device=cdrom" \
  --os-variant ${OS_VARIANT} \
  --console pty,target_type=serial \
  --virt-type kvm --graphics none \
  --import --noautoconsole
# ----- #
        # END irregular indent because heredoc
    done
done

# endregion

# ---

# region : Last

# cleanup
rm -f image.img
echo ""

# endregion

# healthCheck

# collect vmsrvip
declare -a vmsrvip_list=()
for array in "${VM_LIST[@]}"; do
  read -r vmid vmname cpu mem vmsrvip <<< "${array}"
  vmsrvip_list+=("${vmsrvip}")
done

echo "Waiting for runcmd to start..."
while true; do
  if [ ${#vmsrvip_list[@]} -eq 0 ]; then
    break
  fi

  for i in "${!vmsrvip_list[@]}"; do
    if [ -z "${vmsrvip_list[$i]+x}" ]; then
      continue
    fi
    vmsrvip="${vmsrvip_list[$i]}"
    if ! nc -z -w5 "${vmsrvip}" 12345 > /dev/null 2>&1; then
      echo "Waiting per 5s for runcmd on $vmsrvip:12345..."
    else
      unset 'vmsrvip_list[i]'
      # reindex the array
      vmsrvip_list=("${vmsrvip_list[@]}")
    fi
  done
  sleep 5
done

echo -e "\e[1;36m Done! \e[m"

echo "refresh known_hosts"
for array in "${VM_LIST[@]}"; do
  echo "${array}" | while read -r vmid vmname cpu mem vmsrvip; do
    ssh-keygen -R "${vmsrvip}" > /dev/null 2>&1 && ssh-keyscan "${vmsrvip}" >> ~/.ssh/known_hosts 2>/dev/null
  done
done

echo "service ssh restarted"
for array in "${VM_LIST[@]}"; do
  echo "${array}" | while read -r vmid vmname cpu mem vmsrvip; do
    ssh -n melanmeg@"${vmsrvip}" 'sudo systemctl restart ssh'
  done
done

echo "HealthCheck OK."

echo -e "\e[1;36m Install completed!!!! \e[m"
