# kubernetes 1.30 on nobel

## Usage

```bash
$ ansible-playbook --key-file ~/.ssh/KEYFILE -i inventory.yml playbook.yml
```

## Env

- Ubuntu 24.04
- kubernetes 1.30
- Containerd
- Cilium 1.16.1
- KVM
- Haproxy + Keepalived
- NFS

## Host

| hostname | IP             |
| -------- | -------------- |
| k8s-lb-1 | 192.168.11.131 |
| k8s-lb-2 | 192.168.11.132 |
| k8s-cp-1 | 192.168.11.141 |
| k8s-cp-2 | 192.168.11.142 |
| k8s-cp-3 | 192.168.11.143 |
| k8s-wk-1 | 192.168.11.151 |
| k8s-wk-2 | 192.168.11.152 |
| k8s-wk-3 | 192.168.11.153 |

## Time of recreate_cluster

Execution time: 355 seconds
