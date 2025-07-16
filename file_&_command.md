# Project File Manifest & Commands

This document provides a complete list of all files in the Odyssey Entitlements Platform project, a brief explanation of their purpose, and the commands used to execute or interact with them.

---

## 1. Top-Level Scripts

These scripts are run from the project's root directory (`~/odyssey-entitlements/`).

| File | Purpose | Execution Command |
| :--- | :--- | :--- |
| **`gcp_setup.sh`** | Provisions all necessary GCP resources (Project, GKE, Spanner, etc.). | `./gcp_setup.sh` |
| **`setup_workload_identity.sh`** | Configures the secure authentication link between GitHub Actions and GCP. | `./setup_workload_identity.sh` |
| **`gcp_teardown.sh`** | Destroys all created GCP resources to avoid incurring charges. | `./gcp_teardown.sh` |

---

## 2. Backend Application (`app/`)

These files define the core Java Spring Boot microservice.

| File | Purpose |
| :--- | :--- |
| **`app/pom.xml`** | The Maven project file; defines all dependencies and build settings for the backend. |
| **`app/Dockerfile`** | Instructions to build the backend service into a runnable Docker container image. |
| **`app/src/main/java/.../Application.java`** | The main entry point that starts the Spring Boot application. |
| **`app/src/main/java/.../model/Auditor.java`** | The Java data model that maps to the `Auditors` table in the Spanner database. |
| **`app/src/main/java/.../repository/AuditorRepository.java`** | The Spring Data interface for performing database operations (e.g., `findAll`, `saveAll`). |
| **`app/src/main/java/.../service/DataIngestionService.java`** | Contains the business logic to download, parse, and save the ASIC auditor data. |
| **`app/src/main/java/.../controller/AuditorController.java`** | Defines the REST API endpoints (e.g., `/api/auditors`, `/api/auditors/ingest`). |
| **`app/src/main/resources/application.yml`** | The configuration file for the Spring Boot application (e.g., database connection settings). |

#### Common Commands for Backend:
* **Build the Docker image:**
    ```bash
    docker build -t entitlements-service:<tag> ./app
    ```

---

## 3. Frontend Application (`frontend/`)

These files define the Vue.js user interface.

| File | Purpose |
| :--- | :--- |
| **`frontend/Dockerfile`** | Instructions to build the static frontend files into a lightweight NGINX web server container. |
| **`frontend/index.html`** | The main HTML file that structures the web page. |
| **`frontend/app.js`** | The Vue.js JavaScript file containing all UI logic (fetching data, handling clicks). |
| **`frontend/style.css`** | The CSS file that provides styling for the user interface. |

#### Common Commands for Frontend:
* **Build the Docker image:**
    ```bash
    # Navigate into the directory first
    cd frontend
    docker build -t frontend-service:<tag> .
    cd ..
    ```

---

## 4. Kubernetes & Helm (`helm/`)

These files define how the applications are deployed and managed within the GKE cluster.

| File | Purpose |
| :--- | :--- |
| **`helm/entitlements-service/Chart.yaml`** | Contains metadata about the Helm chart (e.g., name, version). |
| **`helm/entitlements-service/values.yaml`** | The main configuration file for the deployment; sets default image names, tags, etc. |
| **`helm/entitlements-service/templates/deployment.yaml`** | The template for the backend service's Kubernetes Deployment resource. |
| **`helm/entitlements-service/templates/service.yaml`** | The template for the backend service's Kubernetes Service resource (internal networking). |
| **`helm/entitlements-service/templates/frontend-deployment.yaml`** | The template for the frontend service's Kubernetes Deployment resource. |
| **`helm/entitlements-service/templates/frontend-service.yaml`** | The template for the frontend service's Kubernetes Service resource (internal networking). |
| **`helm/entitlements-service/templates/ingress.yaml`** | The template for the GKE Ingress, which routes external traffic to the correct service. |
| **`helm/entitlements-service/templates/servicemonitor.yaml`** | A custom resource that tells Prometheus how to find and scrape the backend service. |
| **`helm/entitlements-service/templates/backend-config.yaml`**| A custom resource that defines the backend health check for the GKE Ingress. |

#### Common Commands for Helm:
* **Deploy or upgrade the entire application stack:**
    ```bash
    helm upgrade --install entitlements-service ./helm/entitlements-service \
      --set image.tag=<backend-tag> \
      --set frontendImage.tag=<frontend-tag>
    ```

---

## 5. CI/CD Pipeline (`.github/`)

This file automates the entire build and deployment process.

| File | Purpose |
| :--- | :--- |
| **`.github/workflows/cicd.yml`** | The GitHub Actions workflow file that builds, pushes, and deploys both the backend and frontend services on every push to the `main` branch. |

---

## 6. Documentation (`docs/`)

These files are for presenting and explaining the project.

| File | Purpose |
| :--- | :--- |
| **`docs/runbook.md`** | A guide for support engineers on how to triage and resolve common production alerts. |
| **`docs/interview.md`** | A script and set of talking points for presenting the project during an interview. |

