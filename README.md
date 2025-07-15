# Odyssey Entitlements Platform

This project is a cloud-native Entitlements Management microservice built to showcase modern DevOps and SRE principles using Spring Boot, Docker, Google Cloud Platform (GCP), and Kubernetes.

## Core Technologies
- **Application:** Java 17, Spring Boot 3
- **Database:** Google Cloud Spanner
- **Containerization:** Docker
- **Orchestration:** Google Kubernetes Engine (GKE)
- **CI/CD:** GitHub Actions
- **Observability:** Prometheus & Grafana

---

## Architecture
*(Here you would embed the image generated from the Mermaid diagram above)*

---

## Project Setup from Scratch

### Prerequisites
- `gcloud` CLI installed and authenticated.
- `kubectl` CLI installed.
- `helm` CLI installed.
- `docker` installed and running.
- A GCP Billing Account.

### Step 1: Create GCP Infrastructure
This script provisions all necessary cloud resources. It creates a new GCP project, enables APIs, and sets up GKE, Spanner, and a service account.

1.  Save the code from `gcp_setup.sh` in the project root.
2.  Make it executable: `chmod +x gcp_setup.sh`
3.  Run it: `./gcp_setup.sh`
4.  Follow the prompt to link a billing account in the GCP Console. Note the **new Project ID** it creates.

### Step 2: Configure Authentication
This one-time setup allows GitHub Actions to securely deploy to your new GCP project.

1.  Update the `PROJECT_ID` and `GITHUB_REPO_OWNER` variables in the `setup_workload_identity.sh` script with your new project ID and GitHub username.
2.  Make it executable: `chmod +x setup_workload_identity.sh`
3.  Run it: `./setup_workload_identity.sh`

### Step 3: Manual Deployment & Verification
This process deploys the application manually to confirm everything is working.

1.  **Create Artifact Registry Repo:**
    ```bash
    gcloud artifacts repositories create odyssey-repo \
      --repository-format=docker \
      --location=australia-southeast1 \
      --description="Odyssey Docker repository"
    ```
2.  **Authenticate Docker:**
    ```bash
    gcloud auth configure-docker australia-southeast1-docker.pkg.dev
    ```
3.  **Grant Permissions to Your User:**
    Go to the GCP Console IAM page for your project and grant your user account the **Project Owner** role to avoid permission issues.

4.  **Build, Tag, and Push the Image** (use a unique tag like `:v1`):
    ```bash
    docker build -t entitlements-service:v1 ./app
    docker tag entitlements-service:v1 australia-southeast1-docker.pkg.dev/YOUR_NEW_PROJECT_ID/odyssey-repo/entitlements-service:v1
    docker push australia-southeast1-docker.pkg.dev/YOUR_NEW_PROJECT_ID/odyssey-repo/entitlements-service:v1
    ```

5.  **Create the Spanner Credentials Secret:**
    ```bash
    gcloud iam service-accounts keys create sa-key.json --iam-account="odyssey-sa@YOUR_NEW_PROJECT_ID.iam.gserviceaccount.com"
    kubectl create secret generic spanner-credentials --from-file=GOOGLE_APPLICATION_CREDENTIALS=./sa-key.json
    rm sa-key.json
    ```

6.  **Deploy with Helm:**
    Update the `GCP_PROJECT_ID` in `deployment.yaml` to your new project ID, then run:
    ```bash
    helm upgrade --install entitlements-service ./helm/entitlements-service \
      --set image.repository=australia-southeast1-docker.pkg.dev/YOUR_NEW_PROJECT_ID/odyssey-repo/entitlements-service \
      --set image.tag=v1
    ```

7.  **Test the API:**
    ```bash
    # Get the IP
    EXTERNAL_IP=$(kubectl get svc entitlements-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    # Ingest data
    curl -X POST http://$EXTERNAL_IP/api/auditors/ingest
    # View data
    curl http://$EXTERNAL_IP/api/auditors
    ```
---

## Step 4: Install Monitoring Stack
Install Prometheus and Grafana into the cluster.

1.  **Add Helm Repo:**
    ```bash
    helm repo add prometheus-community [https://prometheus-community.github.io/helm-charts](https://prometheus-community.github.io/helm-charts)
    helm repo update
    ```
2.  **Install the Stack:**
    ```bash
    helm install prometheus prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace
    ```
3.  **Configure Prometheus to Find Your Service:**
    ```bash
    helm upgrade prometheus prometheus-community/kube-prometheus-stack --namespace monitoring \
      --set prometheus.prometheusSpec.serviceMonitorSelector.matchLabels.team=entitlements
    ```

## Step 5: CI/CD Automation
To enable CI/CD, update the `cicd.yml` workflow file with your correct Project ID and Workload Identity Provider details, then push to the `main` branch.





# Odyssey Entitlements Platform

This project is a full-stack, cloud-native Entitlements Management platform built to showcase modern DevOps and SRE principles using a Spring Boot backend, a Vue.js frontend, Docker, and Google Cloud Platform (GCP).

## Core Technologies
- **Backend:** Java 17, Spring Boot
- **Frontend:** Vue.js, NGINX
- **Database:** Google Cloud Spanner
- **Containerization:** Docker & Google Artifact Registry
- **Orchestration:** Google Kubernetes Engine (GKE)
- **CI/CD:** GitHub Actions
- **Observability:** Prometheus & Grafana
- **Networking:** GKE Ingress

---

## Architecture

```mermaid
graph TD
    subgraph "Developer Workflow"
        A[Code Push on 'main'] --> B{GitHub Actions CI/CD};
    end

    subgraph "Google Cloud Platform (GCP)"
        B --> C[Build & Push Images to Artifact Registry];
        C --> D[Deploy to GKE via Helm];

        subgraph "Google Kubernetes Engine (GKE) Cluster"
            E[GKE Ingress] -->|'/'| F[Frontend Pod (Vue.js on NGINX)];
            E -->|'/api/*'| G[Backend Pod (Spring Boot)];
            G --> H[Cloud Spanner Database];
            I[Prometheus] --> G;
            J[Grafana] --> I;
        end
    end

    subgraph "End User"
        K[User's Browser] --> E;
    end
```

---

## Project Setup From Scratch

### Prerequisites
- `gcloud` CLI installed and authenticated.
- `kubectl` CLI installed.
- `helm` CLI installed.
- `docker` installed and running.
- A GCP Billing Account.

### Step 1: Create GCP Infrastructure
This script provisions all necessary cloud resources, including a new GCP project, GKE cluster, and Spanner database.

1.  Save the code from `gcp_setup.sh` to your project root.
2.  Make it executable: `chmod +x gcp_setup.sh`.
3.  Run it: `./gcp_setup.sh`.
4.  Follow the prompt to link a billing account in the GCP Console. Note the **new Project ID** it creates.

### Step 2: Configure Authentication for CI/CD
This allows GitHub Actions to securely deploy to your new GCP project.

1.  Update the `PROJECT_ID` and `GITHUB_REPO_OWNER` variables in the `setup_workload_identity.sh` script.
2.  Make it executable: `chmod +x setup_workload_identity.sh`.
3.  Run it: `./setup_workload_identity.sh`.

### Step 3: Grant Local User Permissions
Grant your user account the necessary roles to push Docker images and manage the project.

1.  Go to the IAM page in the GCP Console for your new project.
2.  Find your user and grant the **Project Owner** role.

### Step 4: Create Artifact Registry Repository
```bash
gcloud artifacts repositories create odyssey-repo \
  --repository-format=docker \
  --location=australia-southeast1 \
  --description="Odyssey Docker repository"
```

### Step 5: Full Application Deployment
With all setup complete, you can now trigger the full CI/CD pipeline.

1.  Update the `workload_identity_provider` in `.github/workflows/cicd.yml` with your project **number** (not ID).
2.  Commit all your project files (`app/`, `frontend/`, `helm/`, etc.) to your GitHub repository.
3.  Push your commit to the `main` branch.
    ```bash
    git add .
    git commit -m "feat: Initial project commit"
    git push origin main
    ```
4.  The GitHub Action will now run, build both images, and deploy the entire stack to GKE.

### Step 6: Access the Application
1.  Wait for the CI/CD pipeline to complete.
2.  Get the public IP address for the Ingress:
    ```bash
    # It may take 3-5 minutes for the address to be assigned
    kubectl get ingress
    ```
3.  Navigate to the IP address in your browser to see the live application.