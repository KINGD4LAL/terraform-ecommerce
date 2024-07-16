#!/bin/bash
set -euo pipefail

if [ -z "$1" ]; then
    exit 1
fi

PROJECT_NAME=$1
REGION="europe-west2"
TF_STATE_BUCKET="${PROJECT_NAME}-tfstate"
FILE_TFVARS="terraform.tfvars"

if [ -d ".terraform" ]; then
    echo "Deleting the .terraform directory..."
    rm -rf .terraform
    echo ".terraform directory has been deleted"
else 
    echo ".terraform folder does not exist"
fi

if [ -f "${FILE_TFVARS}" ]; then
    echo "Deleting ${FILE_TFVARS} from directory"
    rm -rf $FILE_TFVARS
    echo "Deleted ${FILE_TFVARS}"
fi

echo "Created ${FILE_TFVARS}"

echo 'terraform_trigger_branch = "main"' >>"$FILE_TFVARS"

echo "Setting '${PROJECT_NAME}' as default project..."
gcloud config set project "${PROJECT_NAME}" --no-user-output-enabled

echo "Setting region..."
gcloud config set compute/region "${REGION}" --no-user-output-enabled

terraform init -backend-config="bucket=${TF_STATE_BUCKET}"
echo "Set project to '${PROJECT_NAME}' and initialized state bucket: '${TF_STATE_BUCKET}'"