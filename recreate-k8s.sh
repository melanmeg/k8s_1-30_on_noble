#!/bin/bash

KEY_FILE_PATH=~/.ssh/KEFILE
SSH_ALIAS_PHYSICAL=SSH_ALIAS_PHYSICAL_NAME
SSH_ALIAS_CP1=SSH_ALIAS_CP1_NAME
SCRIPT_DIR=~

start_time=$(date +%s)

log_and_execute() {
    local description="$1"
    local script="$2"

    echo "Start: $description"
    ssh $SSH_ALIAS_PHYSICAL "bash $SCRIPT_DIR/$script"
    echo "Completed: $description"
    echo ""
}

recreate_cluster() {
    echo "Recreating the k8s cluster..."
    echo ""

    log_and_execute "Remove the existing cluster" "destroy_cluster.sh"
    log_and_execute "Create a new cluster" "create_cluster.sh"

    echo "Completed recreating the k8s cluster."
    echo ""
}

run_ansible_playbook() {
    echo "Starting Running the ansible playbook."
    ansible-playbook --key-file $KEY_FILE_PATH -i inventory.yml playbook.yml
    echo "Completed Running the ansible playbook."
    echo ""
}

remote_func() {
  while true; do
    not_ready_nodes=$(kubectl get nodes --no-headers | awk '$2 != "Ready" {print $1}')
    if [ -z "$not_ready_nodes" ]; then
      echo "All nodes are Ready!"
      break
    fi
    echo "Waiting for the following nodes to be Ready:"
    echo "$not_ready_nodes"
    sleep 1
  done
}

node_ready_health_check() {
    echo "Start: node_ready_health_check"

    remote_func=$(declare -f remote_func)
    ssh $SSH_ALIAS_CP1 "
      $remote_func
      remote_func
    "

    echo "Completed: node_ready_health_check"
    echo ""
}

recreate_cluster
run_ansible_playbook
node_ready_health_check

end_time=$(date +%s)
execution_time=$((end_time - start_time))

echo "Total Execution time: ${execution_time} seconds"
