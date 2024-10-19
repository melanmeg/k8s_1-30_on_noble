# kubernetes 1.31 on nobel

**Ansible Configuring Kuberenetes 1.31 with Containerd v2 on Ubuntu 24.04 (noble).**

## Usage

```bash
ansible-playbook -i hosts site.yml
```

## Env

- Ubuntu 24.04
- kubernetes 1.31
- Containerd v2.0.0-rc.3
- Cilium 1.16.1
- KVM
- Haproxy + Keepalived
- NFS

## Time of recreate_cluster

Execution time: 179 seconds
