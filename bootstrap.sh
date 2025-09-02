#!/bin/bash

# Bootstrap script for setting up Jellyfin media server
# Usage: ./bootstrap.sh <username> <ip_address>

set -e

if [ $# -ne 2 ]; then
    echo "Usage: $0 <username> <ip_address>"
    echo "Example: $0 myuser 192.168.1.100"
    exit 1
fi

USERNAME="$1"
IP_ADDRESS="$2"

# Check if SSH public key exists
PUBLIC_KEY_FILE="$HOME/.ssh/id_rsa.pub"
if [ ! -f "$PUBLIC_KEY_FILE" ]; then
    echo "No SSH public key found at $PUBLIC_KEY_FILE"
    echo "Generating new SSH key pair..."
    ssh-keygen -t rsa -b 4096 -f "$HOME/.ssh/id_rsa" -N ""
fi

echo "Copying public key to ${USERNAME}@${IP_ADDRESS}..."
ssh-copy-id -i "$PUBLIC_KEY_FILE" "${USERNAME}@${IP_ADDRESS}"

echo "Running Ansible playbook to set up Jellyfin media server on ${USERNAME}@${IP_ADDRESS}..."

# Update inventory with the provided IP and username
sed -i.bak "s/ansible_host: .*/ansible_host: ${IP_ADDRESS}/" inventory.yml
sed -i.bak "s/ansible_user: .*/ansible_user: ${USERNAME}/" inventory.yml

# Run the Jellyfin playbook
ansible-playbook -i inventory.yml jellyfin-playbook.yml

echo "Successfully set up Jellyfin media server on ${USERNAME}@${IP_ADDRESS}"
echo "Access Jellyfin at: http://${IP_ADDRESS}:8096"