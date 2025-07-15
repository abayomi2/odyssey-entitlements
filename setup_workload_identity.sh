#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

# --- Configurable Inputs ---
PROJECT_ID="${1:-odyssey123-1752491152}"
SERVICE_ACCOUNT_NAME="${2:-odyssey-sa}"
GITHUB_REPO_OWNER="${3:-abayomi2}"
GITHUB_REPO_NAME="${4:-odyssey-entitlements}"

# --- Derived Variables ---
SA_EMAIL="${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"
POOL_NAME="github-pool"
PROVIDER_NAME="github-provider"

# --- Main Execution ---
echo "🚀 Starting Workload Identity Federation setup for project: ${PROJECT_ID}"

echo "🔧 Setting active project to ${PROJECT_ID}"
gcloud config set project "${PROJECT_ID}"

echo "👤 Verifying Service Account: ${SERVICE_ACCOUNT_NAME}"
if ! gcloud iam service-accounts describe "${SA_EMAIL}" --project="${PROJECT_ID}" &>/dev/null; then
  echo "   -> Service account not found, creating..."
  gcloud iam service-accounts create "${SERVICE_ACCOUNT_NAME}" \
    --project="${PROJECT_ID}" \
    --display-name="Odyssey GitHub Actions SA"
else
  echo "   -> Service account already exists."
fi

echo "🏗️ Verifying Workload Identity Pool: ${POOL_NAME}"
if ! gcloud iam workload-identity-pools describe "${POOL_NAME}" --project="${PROJECT_ID}" --location="global" &>/dev/null; then
  echo "   -> Pool not found, creating..."
  gcloud iam workload-identity-pools create "${POOL_NAME}" \
    --project="${PROJECT_ID}" \
    --location="global" \
    --display-name="GitHub Actions Pool"
else
  echo "   -> Pool already exists."
fi

echo "🌐 Verifying OIDC Provider: ${PROVIDER_NAME}"
if ! gcloud iam workload-identity-pools providers describe "${PROVIDER_NAME}" --project="${PROJECT_ID}" --location="global" --workload-identity-pool="${POOL_NAME}" &>/dev/null; then
  echo "   -> Provider not found, creating..."
  gcloud iam workload-identity-pools providers create-oidc "${PROVIDER_NAME}" \
    --project="${PROJECT_ID}" \
    --location="global" \
    --workload-identity-pool="${POOL_NAME}" \
    --issuer-uri="https://token.actions.githubusercontent.com" \
    --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository" \
    --attribute-condition="attribute.repository == '${GITHUB_REPO_OWNER}/${GITHUB_REPO_NAME}'" # <-- ADDED THIS LINE FOR SECURITY
else
    echo "   -> Provider already exists."
fi

echo "🔐 Binding IAM policy to link GitHub repo to the service account..."
POOL_ID=$(gcloud iam workload-identity-pools describe "${POOL_NAME}" --project="${PROJECT_ID}" --location="global" --format='value(name)')
gcloud iam service-accounts add-iam-policy-binding "${SA_EMAIL}" \
  --project="${PROJECT_ID}" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/${POOL_ID}/attribute.repository/${GITHUB_REPO_OWNER}/${GITHUB_REPO_NAME}"

echo "✅ Setup complete!"