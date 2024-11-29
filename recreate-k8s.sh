#!/bin/bash

start_time=$(date +%s)

log_and_execute() {
    local description="$1"
    local script="$2"

    echo "Start: $description"
    ssh base2 "bash ~/kvm/$script"
    echo "Completed: $description"
    echo ""
}

recreate_cluster() {
    echo "Recreating the k8s cluster..."
    echo ""

    log_and_execute "Remove the existing cluster" "k8sd.sh"
    log_and_execute "Remove the k8s pvc data" "del-pvc.sh"
    log_and_execute "Create a new cluster" "k8sa.sh"

    echo "Completed recreating the k8s cluster."
    echo ""
}

run_ansible_playbook() {
    echo "Starting Running the ansible playbook."
    ansible-playbook --key-file ~/.ssh/main -i inventory.yml playbook.yml
    echo "Completed Running the ansible playbook."
    echo ""
}

recreate_cluster
run_ansible_playbook

end_time=$(date +%s)
execution_time=$((end_time - start_time))

echo "Total Execution time: ${execution_time} seconds"
