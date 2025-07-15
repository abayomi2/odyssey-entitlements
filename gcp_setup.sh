
#!/bin/bash
set -e # Exit immediately if a command fails

# --- Configuration ---
export PROJECT_ID="odyssey123-1752491152"
# --- End of Configuration ---

export GKE_CLUSTER_NAME="odyssey-cluster"
export SPANNER_INSTANCE_ID="entitlements-instance"
export SPANNER_DATABASE_ID="auditor-db"
export REGION="australia-southeast1"
export SERVICE_ACCOUNT_NAME="odyssey-sa"

echo "🚀 Starting GCP setup for existing project: $PROJECT_ID"

# 1. Set the active project in gcloud
gcloud config set project $PROJECT_ID

# 2. Link Billing Account
echo "🛑 MANUAL STEP: Ensure billing is linked for project '$PROJECT_ID'"
echo "Visit: https://console.cloud.google.com/billing"
read -p "Press [Enter] to continue after verifying billing..."

# 3. Enable APIs
echo "Enabling necessary APIs..."
gcloud services enable \
  compute.googleapis.com \
  container.googleapis.com \
  spanner.googleapis.com \
  containerregistry.googleapis.com \
  secretmanager.googleapis.com \
  iam.googleapis.com

# 4. Create GKE Cluster if it doesn't exist
if ! gcloud container clusters describe $GKE_CLUSTER_NAME --region $REGION &>/dev/null; then
  echo "Creating GKE Cluster..."
  gcloud container clusters create $GKE_CLUSTER_NAME \
    --region $REGION \
    --num-nodes=2 \
    --machine-type=e2-medium \
    --enable-ip-alias \
    --disk-size="30GB"
else
  echo "✅ GKE Cluster '$GKE_CLUSTER_NAME' already exists."
fi

# 5. Create Spanner Instance & Database if they don't exist
if ! gcloud spanner instances describe $SPANNER_INSTANCE_ID &>/dev/null; then
  echo "Creating Spanner Instance..."
  gcloud spanner instances create $SPANNER_INSTANCE_ID \
    --config=regional-$REGION \
    --description="Entitlements Spanner Instance" \
    --nodes=1
  
  echo "Creating Spanner Database..."
  gcloud spanner databases create $SPANNER_DATABASE_ID \
    --instance=$SPANNER_INSTANCE_ID \
    --ddl="CREATE TABLE Auditors (AuditorId STRING(36) NOT NULL, Name STRING(255), Company STRING(255), RegistrationDate STRING(MAX)) PRIMARY KEY (AuditorId)"
else
  echo "✅ Spanner Instance '$SPANNER_INSTANCE_ID' and its database already exist."
fi

# 6. Create Service Account if it doesn't exist
SA_EMAIL="${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"
if ! gcloud iam service-accounts describe $SA_EMAIL &>/dev/null; then
  echo "Creating Service Account..."
  gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME \
    --display-name="Odyssey Service Account"
else
  echo "✅ Service Account '$SERVICE_ACCOUNT_NAME' already exists."
fi

echo "Assigning necessary IAM roles..."
gcloud projects add-iam-policy-binding $PROJECT_ID --member="serviceAccount:$SA_EMAIL" --role="roles/spanner.databaseUser"
gcloud projects add-iam-policy-binding $PROJECT_ID --member="serviceAccount:$SA_EMAIL" --role="roles/container.developer"
gcloud projects add-iam-policy-binding $PROJECT_ID --member="serviceAccount:$SA_EMAIL" --role="roles/storage.objectAdmin"
gcloud projects add-iam-policy-binding $PROJECT_ID --member="serviceAccount:$SA_EMAIL" --role="roles/secretmanager.secretAccessor"

echo "✅ GCP Setup Complete!"