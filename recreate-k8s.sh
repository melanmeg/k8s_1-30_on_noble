#!/bin/bash

KEY_FILE_PATH=~/.ssh/main
SSH_ALIAS=base2
SCRIPT_DIR=~/kvm

# KEY_FILE_PATH=~/.ssh/KEFILE
# SSH_ALIAS=ALIAS_NAME
# SCRIPT_DIR=~

start_time=$(date +%s)

log_and_execute() {
    local description="$1"
    local script="$2"

    echo "Start: $description"
    ssh $SSH_ALIAS "bash $SCRIPT_DIR/$script"
    echo "Completed: $description"
    echo ""
}

recreate_cluster() {
    echo "Recreating the k8s cluster..."
    echo ""

    log_and_execute "Remove the existing cluster" "k8sd.sh"
    log_and_execute "Create a new cluster" "k8sa.sh"

    # log_and_execute "Remove the existing cluster" "destroy_cluster.sh"
    # log_and_execute "Create a new cluster" "create_cluster.sh"

    echo "Completed recreating the k8s cluster."
    echo ""
}

run_ansible_playbook() {
    echo "Starting Running the ansible playbook."
    ansible-playbook --key-file $KEY_FILE_PATH -i inventory.yml playbook.yml
    echo "Completed Running the ansible playbook."
    echo ""
}

recreate_cluster
run_ansible_playbook

end_time=$(date +%s)
execution_time=$((end_time - start_time))

echo "Total Execution time: ${execution_time} seconds"
