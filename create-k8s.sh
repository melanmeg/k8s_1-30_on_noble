#!/bin/bash

# variables
# KEY_FILE_PATH=~/.ssh/KEFILE
# SSH_ALIAS_CP1=SSH_ALIAS_CP1_NAME
TERRAFORM_DIR=./terraform/env
ANSIBLE_DIR=./ansible

KEY_FILE_PATH=~/.ssh/main
SSH_ALIAS_CP1=cp4

# Start the timer
start_time=$(date +%s)

# Function to recreate the k8s cluster
run_terraform() {
    echo "Recreating the k8s cluster..."
    terraform -chdir=$TERRAFORM_DIR init -input=false
    terraform -chdir=$TERRAFORM_DIR apply -auto-approve -input=false
    echo "Completed recreating the k8s cluster."
    echo ""
}

# Function to run the ansible playbook
run_ansible_playbook() {
    echo "Starting Running the ansible playbook."
    ansible-playbook --key-file $KEY_FILE_PATH -i $ANSIBLE_DIR/inventory.yml $ANSIBLE_DIR/playbook.yml
    echo "Completed Running the ansible playbook."
    echo ""
}

# Function to check if all nodes are Ready
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

# Function to check if all nodes are Ready
node_ready_health_check() {
    echo "Start: node_ready_health_check"

    remote_func=$(declare -f remote_func)
    ssh -o StrictHostKeyChecking=no $SSH_ALIAS_CP1 "
      $remote_func
      remote_func
    "

    echo "Completed: node_ready_health_check"
    echo ""
}

run_terraform
run_ansible_playbook
node_ready_health_check

# End the timer
end_time=$(date +%s)
execution_time=$((end_time - start_time))

echo "Total Execution time: ${execution_time} seconds"
