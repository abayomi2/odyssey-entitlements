
#!/bin/bash
set -e # Exit immediately if a command fails

# --- Configuration ---
# Set the project ID to the one you want to delete.
export PROJECT_ID="odyssey123"
# --- End of Configuration ---

echo "🛑 This script will permanently delete all resources in project '$PROJECT_ID'."
read -p "Press [Enter] to confirm you wish to continue..."

# 1. Set the active project to ensure we are deleting from the correct one
gcloud config set project $PROJECT_ID

# 2. Delete the GKE Cluster
# The --quiet flag prevents interactive prompts.
echo "Deleting GKE Cluster 'odyssey-cluster'..."
gcloud container clusters delete odyssey-cluster --region=australia-southeast1 --quiet

# 3. Delete the Spanner Instance
echo "Deleting Spanner Instance 'entitlements-instance'..."
gcloud spanner instances delete entitlements-instance --quiet

# 4. Delete the Service Account
echo "Deleting Service Account 'odyssey-sa'..."
gcloud iam service-accounts delete "odyssey-sa@${PROJECT_ID}.iam.gserviceaccount.com" --quiet

# 5. Delete the entire GCP Project
# This is the final cleanup step.
echo "Deleting GCP Project '$PROJECT_ID'..."
gcloud projects delete $PROJECT_ID --quiet

echo "✅ Teardown complete. All specified resources have been marked for deletion."