#!/bin/bash

# --- Configuration ---
export PROJECT_ID="macquarie-odyssey-$(random_string)" # Replace with a unique project ID
export GKE_CLUSTER_NAME="odyssey-cluster"
export SPANNER_INSTANCE_ID="entitlements-instance"
export SPANNER_DATABASE_ID="auditor-db"
export REGION="australia-southeast1"
export GCR_REPO_NAME="entitlements-service"
export SERVICE_ACCOUNT_NAME="odyssey-sa"

echo "🚀 Starting GCP setup for project: $PROJECT_ID"

# --- Project & Billing ---
echo "Creating GCP Project..."
gcloud projects create $PROJECT_ID
gcloud config set project $PROJECT_ID
# Link billing account (manual step required)
echo "🛑 MANUAL STEP: Please link a billing account to the project in the GCP Console."
read -p "Press [Enter] to continue after linking billing..."

# --- Enable APIs ---
echo "Enabling necessary APIs..."
gcloud services enable \
  compute.googleapis.com \
  container.googleapis.com \
  spanner.googleapis.com \
  containerregistry.googleapis.com \
  secretmanager.googleapis.com

# --- GKE Cluster ---
echo "Creating GKE Cluster..."
gcloud container clusters create $GKE_CLUSTER_NAME \
  --region $REGION \
  --num-nodes=2 \
  --machine-type=e2-medium \
  --enable-ip-alias

# --- Spanner Instance & Database ---
echo "Creating Spanner Instance and Database..."
gcloud spanner instances create $SPANNER_INSTANCE_ID \
  --config=regional-$REGION \
  --description="Entitlements Spanner Instance" \
  --nodes=1

gcloud spanner databases create $SPANNER_DATABASE_ID \
  --instance=$SPANNER_INSTANCE_ID \
  --ddl="CREATE TABLE Auditors (AuditorId STRING(36) NOT NULL, Name STRING(255), Company STRING(255), RegistrationDate DATE) PRIMARY KEY (AuditorId)"

# --- Service Account & Permissions ---
echo "Creating Service Account..."
gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME \
  --display-name="Odyssey Service Account"

SA_EMAIL=$(gcloud iam service-accounts list --filter="displayName:$SERVICE_ACCOUNT_NAME" --format='value(email)')

echo "Assigning necessary roles to the Service Account..."
gcloud projects add-iam-policy-binding $PROJECT_ID --member="serviceAccount:$SA_EMAIL" --role="roles/spanner.databaseUser"
gcloud projects add-iam-policy-binding $PROJECT_ID --member="serviceAccount:$SA_EMAIL" --role="roles/container.developer"
gcloud projects add-iam-policy-binding $PROJECT_ID --member="serviceAccount:$SA_EMAIL" --role="roles/storage.objectAdmin" # For GCR
gcloud projects add-iam-policy-binding $PROJECT_ID --member="serviceAccount:$SA_EMAIL" --role="roles/secretmanager.secretAccessor"

echo "✅ GCP Setup Complete!"
echo "Project ID: $PROJECT_ID"
echo "Service Account Email: $SA_EMAIL"