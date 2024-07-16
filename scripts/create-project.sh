#!/bin/bash
set -euo pipefail

# guard clause
if [ -z "$1" ]; then
	exit 1
fi

# set paramters
PROJECT_NAME=$1
BILLING_ACCOUNT_ID="01FE47-943EC2-872F4E"
TF_STATE_BUCKET="${PROJECT_NAME}-tfstate"
REGION="europe-west2"
FILE_TFVARS="terraform.tfvars"

# Check if the .terraform directory exists
if [ -d ".terraform" ]; then
	echo "Deleting the .terraform directory..."
	rm -rf .terraform
	echo ".terraform directory deleted."
else
	echo ".terraform directory does not exist."
fi

if [ -f "cloudbuild/${PROJECT_NAME}.yaml" ]; then
	echo "${PROJECT_NAME}.yaml already exists"
else
	cp "cloudbuild/cloudbuild_template.yaml" "cloudbuild/${PROJECT_NAME}.yaml"
	echo "Copied cloudbuild_template to ${PROJECT_NAME}.yaml"
fi

if [ -f "${FILE_TFVARS}" ]; then
	echo "Deleting ${FILE_TFVARS} from directory"
	rm -rf $FILE_TFVARS
	echo "Deleted ${FILE_TFVARS}"
fi

echo "project = \"$PROJECT_NAME\"" >"$FILE_TFVARS"
echo "Created ${FILE_TFVARS}"

{
	echo 'terraform_trigger_branch = "main"'
} >>"$FILE_TFVARS"

# create project
if gcloud projects describe "${PROJECT_NAME}" >/dev/null 2>&1; then
	echo "GCP Project '${PROJECT_NAME}' already exists, skipping creation..."
else
	echo "Creating project '${PROJECT_NAME}'"
	gcloud projects create "${PROJECT_NAME}" \
		--set-as-default \
		--no-user-output-enabled
fi

# set target project
echo "Setting '${PROJECT_NAME}' as default project..."
gcloud config set project "${PROJECT_NAME}" --no-user-output-enabled

# link billing account
echo "Linking '${PROJECT_NAME}' to personal billing account..."
gcloud beta billing projects link "${PROJECT_NAME}" \
	--billing-account $BILLING_ACCOUNT_ID \
	--no-user-output-enabled

# enable apis
echo "enabling apis"
gcloud services enable compute.googleapis.com \
	--project "${PROJECT_NAME}" \
	--quiet
gcloud services enable cloudbuild.googleapis.com \
	--project "${PROJECT_NAME}" \
	--quiet

# set project region
echo "Setting region..."
gcloud config set compute/region "${REGION}" --no-user-output-enabled

# delete default firewall rules if it exists
if gcloud compute firewall-rules describe default-allow-icmp >/dev/null 2>&1; then
	echo "Deleting default firewall rules..."
	gcloud compute firewall-rules delete default-allow-icmp default-allow-internal default-allow-rdp default-allow-ssh --no-user-output-enabled --quiet || true
else
	echo "Default rules do not exist, skipping ..."
fi

# delete default network if it exists
if gcloud compute networks describe default >/dev/null 2>&1; then
	echo "Deleting default network..."
	gcloud compute networks delete "default" --no-user-output-enabled --quiet || true
else
	echo "Default network does not exist, skipping ..."
fi

# create our terraform state bucket
if gsutil ls "gs://${TF_STATE_BUCKET}" >/dev/null 2>&1; then
	echo "Terraform state bucket exists, skipping creation ..."
else
	echo "Creating Terraform state bucket ..."
	gsutil mb -b on -p "${PROJECT_NAME}" -c regional -l "${REGION}" "gs://${TF_STATE_BUCKET}" || true
	gsutil versioning set on gs://"$TF_STATE_BUCKET"
fi

# initialise infrastructure
terraform init -backend-config="bucket=${TF_STATE_BUCKET}"
