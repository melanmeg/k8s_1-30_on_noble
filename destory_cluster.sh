#!/bin/bash

cd "$(dirname "$0")" || exit

VM_LIST=(
  test-k8s-lb-1
  test-k8s-lb-2
  test-k8s-cp-1
  test-k8s-cp-2
  test-k8s-cp-3
  test-k8s-wk-1
  test-k8s-wk-2
  test-k8s-wk-3
)

# vm destroy
for array in "${VM_LIST[@]}"
do
  sudo virsh destroy "${array}"
  sudo virsh undefine "${array}" --remove-all-storage
done
