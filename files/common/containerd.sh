#!/bin/bash
set -eux

# ref: https://gist.github.com/inductor/1acdde825487cfd7707ee92c3b22078e

ARCH="amd64"
OS="linux"
CONTAINERD_VERSION="2.0.0-rc.3"
RUNC_VERSION="1.1.13"
CNI_VERSION="1.5.1"

cd /tmp

# Install containerd
aria2c -x 16 -s 16 -k 1M https://github.com/containerd/containerd/releases/download/v${CONTAINERD_VERSION}/containerd-${CONTAINERD_VERSION}-${OS}-${ARCH}.tar.gz
sudo tar Cxzvf /usr/local containerd-${CONTAINERD_VERSION}-${OS}-${ARCH}.tar.gz

# Configure containerd
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml > /dev/null

if grep -q "SystemdCgroup = true" "/etc/containerd/config.toml"; then
  echo "Config found, skip rewriting..."
else
  sudo sed -i -e "s/SystemdCgroup \= false/SystemdCgroup \= true/g" /etc/containerd/config.toml
fi

sudo curl -L https://raw.githubusercontent.com/containerd/containerd/main/containerd.service -o /lib/systemd/system/containerd.service

sudo systemctl daemon-reload
sudo systemctl enable --now containerd

# Install runc
aria2c -x 16 -s 16 -k 1M https://github.com/opencontainers/runc/releases/download/v${RUNC_VERSION}/runc.${ARCH}
sudo install -m 755 runc.${ARCH} /usr/local/sbin/runc

# Install CNI plugin
aria2c -x 16 -s 16 -k 1M https://github.com/containernetworking/plugins/releases/download/v${CNI_VERSION}/cni-plugins-${OS}-${ARCH}-v${CNI_VERSION}.tgz
sudo mkdir -p /opt/cni/bin
sudo tar Cxzvf /opt/cni/bin cni-plugins-${OS}-${ARCH}-v${CNI_VERSION}.tgz

# fix: https://github.com/cilium/cilium/issues/23838
sudo chown -R root:root /opt/cni/bin
