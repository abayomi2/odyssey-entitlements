# Interview Walk-through Guide: The Odyssey Platform

*(Start with your architecture diagram on the screen)*

## Introduction

"For this project, I designed and built an end-to-end entitlements management microservice. The goal was to demonstrate a production-ready platform, focusing on the core DevOps principles of automation, security, and observability."

"The architecture has three main parts: the application itself, the GCP infrastructure it runs on, and the CI/CD pipeline that automates the entire process."

---
## Part 1: The Application Layer

"The service is a **Spring Boot** application written in Java. I chose Spring Boot because it's a robust, industry-standard framework that makes it fast to build secure, standalone web applications and APIs."

### API Layer (REST & GraphQL)
"The application exposes data through two types of APIs. A standard **REST API** for simple requests, and a **GraphQL endpoint**. I included GraphQL because it’s highly efficient for a platform like this. It allows different consuming systems to request *exactly* the data fields they need and nothing more, which reduces network load and improves performance."

### Data Ingestion
"A key feature is the data ingestion service, which pulls auditor data from an external government CSV file, parses it, and stores it in our database. This simulates handling a real-world data feed."

---
## Part 2: The GCP Infrastructure

"The entire platform runs on **Google Cloud Platform (GCP)**, which I chose for its powerful managed services."

### Compute: Google Kubernetes Engine (GKE)
"The application is containerized with **Docker** and runs on **GKE**, which is Google's managed Kubernetes service. Using GKE means we don't have to worry about managing the Kubernetes control plane; we can just focus on our application. It gives us high availability and scalability out of the box. I defined all the Kubernetes resources using **Helm** charts, which makes the deployment process configurable and repeatable."

### Database: Cloud Spanner
"For the database, I selected **Cloud Spanner**. An entitlements platform is a critical, tier-1 service, so I needed a database that could guarantee consistency and high availability. Spanner is a globally distributed SQL database that provides both, along with horizontal scaling and zero downtime. It's the perfect choice for a system that cannot fail."

### Security: Secret Management
"Security was a top priority. All credentials, like the key for the Spanner database, are managed using **Kubernetes Secrets**. The application pod mounts this secret as a file at runtime. This means no keys are ever stored in the Docker image or in the source code. For the CI/CD pipeline, I used **Workload Identity Federation**, which is Google's modern, keyless method for allowing GitHub Actions to securely authenticate with GCP."

---
## Part 3: The DevOps & SRE Components

"This is where we bring it all together. A working application is great, but a reliable, observable, and automated one is what's needed for production."

### CI/CD Automation: GitHub Actions
"I created a complete **CI/CD pipeline** with GitHub Actions. When code is pushed to the `main` branch, the pipeline automatically builds the Docker image, pushes it to Google's **Artifact Registry**, and deploys the new version to GKE using our Helm chart. This automation makes our releases fast and reliable."

### Observability: Prometheus & Grafana
"Finally, the platform is fully observable."

**(Bring up your Grafana dashboard on screen)**

"The application uses **Micrometer** to export detailed metrics, which are scraped by **Prometheus** and visualized in this **Grafana** dashboard. As you can see, we're tracking not just technical metrics like JVM memory, but also key business indicators like **API Request Rate**, **Average API Latency**, and the **API Error Rate**. This allows us to understand not just if the service is 'up', but if it's healthy and performing well for its users."

**(Bring up the `runbook.md` file)**

"To support this, I created this **runbook**. If an alert fires—for example, if latency spikes—this document gives an on-call engineer the exact steps to triage the issue, from checking the dashboard to running diagnostic commands. This is crucial for reducing Mean Time to Resolution (MTTR) in a production environment."

---
## Conclusion
"In summary, this project demonstrates a complete, secure, and observable cloud-native platform. It's built with the same principles of automation and reliability that are essential for a strategic system like an entitlements platform."