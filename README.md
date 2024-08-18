# kubernetes 1.31 on nobel

**Ansible Configuring Kuberenetes 1.31 with Containerd v2 on Ubuntu 24.04 (nobel).**

## Usage

```bash
ansible-playbook...
```

## memo

```bash
# Error

## token
kubeadm token create --print-join-command

## socket

### 調査コマンド
ss -lx | grep containerd.sock
ss -lx | grep '/var/run/containerd/containerd.sock' # ソケットのリスニング状況を確認
sudo lsof | grep '/var/run/containerd/containerd.sock' # ソケットを使用しているプロセスを確認
ps aux | grep containerd # containerd プロセスの確認


### 修正案1
$ vim /var/lib/kubelet/config.yaml
container-runtime-endpoint: unix:///run/containerd/containerd.sock
$ sudo ln -s /run/containerd/containerd.sock /var/run/containerd/containerd.sock
$ sudo systemctl restart kubelet

### 修正案2
$ sudo ln -s /run/containerd/containerd.sock /var/run/containerd/containerd.sock
$ sudo systemctl restart kubelet

### migrate
$ kubeadm config migrate --old-config ./join_kubeadm_cp.yaml --new-config ./new_join_kubeadm_cp.yaml

```
