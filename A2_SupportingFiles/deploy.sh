#!/bin/bash

set -e # Bail on first sign of trouble

echo "Running Alpine. Inc Deployment Script.."

echo "Testing AWS credentials"
aws sts get-caller-identity

cd infra

path_to_ssh_key="alpine_sdo_key" # Also reflected in you.auto.tfvars, but with ".pub" suffix
echo "Creating SSH keypair ${path_to_ssh_key}..."
ssh-keygen -C ubuntu@alpine -f "${path_to_ssh_key}" -N ''

echo "Initialising Terraform..."
terraform init
echo "Validating Terraform configuration..."
terraform validate
echo "Running terraform apply, get ready to review and approve actions..."
terraform apply

echo "Running ansible to configure Foo App"
cd .. # Back to root of lab
ansible-playbook ansible/app-playbook.yml -i ansible/inventory1.yml --private-key "infra/${path_to_ssh_key}"

echo "Running ansible to configure foo database"
cd ..
ansible-playbook ansible/db-playbook.yml -i ansible/inventory2.yml --private-key "infra/${path_to_ssh_key}"
