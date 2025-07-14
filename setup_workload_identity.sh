#!/bin/bash
set -e

### --- Configurable Inputs ---
PROJECT_ID="${1:-odyssey123}"
SERVICE_ACCOUNT_NAME="${2:-odyssey-sa}"
GITHUB_REPO_OWNER="${3:-abayomi2}"
GITHUB_REPO_NAME="${4:-odyssey-entitlements}"

### --- Derived Variables ---
SA_EMAIL="${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"
POOL_NAME="github-pool"
PROVIDER_NAME="github-provider"

### --- Functions ---
function set_active_project() {
  echo "🔧 Setting active project to ${PROJECT_ID}"
  gcloud config set project "${PROJECT_ID}"
}

function get_project_number() {
  echo "🔍 Fetching project number..."
  PROJECT_NUMBER=$(gcloud projects describe "${PROJECT_ID}" --format='value(projectNumber)')
  echo "🧾 Project number is: ${PROJECT_NUMBER}"
}

function create_service_account() {
  echo "👤 Creating service account: ${SERVICE_ACCOUNT_NAME}"
  gcloud iam service-accounts create "${SERVICE_ACCOUNT_NAME}" \
    --project="${PROJECT_ID}" \
    --display-name="GitHub Actions Service Account" \
    || echo "Service account already exists: ${SA_EMAIL}"
}

function create_identity_pool() {
  echo "🏗️ Creating Workload Identity Pool: ${POOL_NAME}"
  gcloud iam workload-identity-pools create "${POOL_NAME}" \
    --project="${PROJECT_ID}" \
    --location="global" \
    --display-name="GitHub Actions Pool" \
    || echo "✔️ Pool '${POOL_NAME}' already exists."
}

function get_pool_id() {
  POOL_ID=$(gcloud iam workload-identity-pools describe "${POOL_NAME}" \
    --project="${PROJECT_ID}" \
    --location="global" \
    --format='value(name)')
  echo "🔗 Pool ID: ${POOL_ID}"
}

function create_oidc_provider() {
  echo "🌐 Creating OIDC Provider: ${PROVIDER_NAME}"
  gcloud iam workload-identity-pools providers create-oidc "${PROVIDER_NAME}" \
    --project="${PROJECT_ID}" \
    --location="global" \
    --workload-identity-pool="${POOL_NAME}" \
    --issuer-uri="https://token.actions.githubusercontent.com" \
    --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository" \
    || echo "✔️ Provider '${PROVIDER_NAME}' already exists."
}

function bind_iam_policy() {
  echo "🔐 Binding IAM policy to allow GitHub Actions to impersonate the service account..."
  gcloud iam service-accounts add-iam-policy-binding "${SA_EMAIL}" \
    --project="${PROJECT_ID}" \
    --role="roles/iam.workloadIdentityUser" \
    --member="principalSet://iam.googleapis.com/${POOL_ID}/attribute.repository/${GITHUB_REPO_OWNER}/${GITHUB_REPO_NAME}" \
    || echo "⚠️ Failed to bind IAM policy to '${SA_EMAIL}'"
}

### --- Execution ---
echo "🚀 Starting Workload Identity Federation setup for project: ${PROJECT_ID}"
set_active_project
get_project_number
create_service_account
create_identity_pool
get_pool_id
create_oidc_provider
bind_iam_policy
echo "✅ Setup complete for project '${PROJECT_ID}'"



# #!/bin/bash
# set -e # Exit immediately if a command exits with a non-zero status.

# # --- Configuration ---
# # ‼️ UPDATE THESE THREE VARIABLES with your specific details.
# export PROJECT_ID="odyssey123"
# export GITHUB_REPO_OWNER="abayomi2"
# export GITHUB_REPO_NAME="odyssey-entitlements"
# # --- End of Configuration ---

# # Derived variables
# SERVICE_ACCOUNT_NAME="odyssey-sa"
# SA_EMAIL="${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"
# POOL_NAME="github-pool"
# PROVIDER_NAME="github-provider"

# echo "🚀 Starting Workload Identity Federation setup for project: ${PROJECT_ID}"

# # 1. Set the active project
# gcloud config set project ${PROJECT_ID}

# # 2. Get Project Number
# echo "Fetching project number..."
# PROJECT_NUMBER=$(gcloud projects describe "${PROJECT_ID}" --format='value(projectNumber)')
# echo "Project number is: ${PROJECT_NUMBER}"

# # 3. Create Workload Identity Pool
# echo "Creating Workload Identity Pool: ${POOL_NAME}..."
# gcloud iam workload-identity-pools create "${POOL_NAME}" \
#   --project="${PROJECT_ID}" \
#   --location="global" \
#   --display-name="GitHub Actions Pool" \
#   || echo "Pool '${POOL_NAME}' already exists."

# # 4. Get full ID of the pool
# POOL_ID=$(gcloud iam workload-identity-pools describe "${POOL_NAME}" \
#   --project="${PROJECT_ID}" \
#   --location="global" --format='value(name)')
# echo "Pool ID is: ${POOL_ID}"

# # 5. Create the OIDC Provider for the pool
# echo "Creating OIDC Provider: ${PROVIDER_NAME}..."
# gcloud iam workload-identity-pools providers create-oidc "${PROVIDER_NAME}" \
#   --project="${PROJECT_ID}" \
#   --location="global" \
#   --workload-identity-pool="${POOL_NAME}" \
#   --issuer-uri="https://token.actions.githubusercontent.com" \
#   --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository" \
#   || echo "Provider '${PROVIDER_NAME}' already exists."

# # 6. Allow authentications from the GitHub repo to impersonate the Service Account
# echo "Binding IAM policy..."
# gcloud iam service-accounts add-iam-policy-binding "${SA_EMAIL}" \
#   --project="${PROJECT_ID}" \
#   --role="roles/iam.workloadIdentityUser" \
#   --member="principalSet://iam.googleapis.com/${POOL_ID}/attribute.repository/${GITHUB_REPO_OWNER}/${GITHUB_REPO_NAME}"

# echo "✅ Workload Identity Federation setup is complete!"