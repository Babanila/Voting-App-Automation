#!/usr/bin/env bash
set -euo pipefail

export $(grep -v '^#' .env | xargs)

export ANSIBLE_HOST_KEY_CHECKING=False

ansible-playbook ansible/site.yml

echo "✅ Deployment finished successfully"
