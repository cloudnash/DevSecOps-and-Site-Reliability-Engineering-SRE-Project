# DevSecOps & Site Reliability Engineering (SRE) Assessment

## Overview

You have been assigned to deploy and manage a new microservice for our infrastructure. The application is a lightweight Python service that is known to have a memory leak, it starts at around 100MB and slowly increases its memory footprint to 1GB over the course of 5 minutes. It also generates standard application logs. 

Your mission is to build a secure delivery pipeline, implement a GitOps deployment strategy, and set up robust observability and alerting to catch the application when it inevitably crashes.

**Rules:**
- Everything should be done using free/open-source tools running locally (e.g., Minikube, Kind, K3d). No cloud accounts are required.
- Security controls are currently enforced **only** in the CI/CD pipeline. 
- Provide clear documentation on your setup, architecture, and instructions to reproduce your environment.


## Flowchart

<img width="2807" height="8192" alt="ArgoCD Kubernetes GitOps Deployment Pipeline-2026-10-29-092910" src="https://github.com/user-attachments/assets/7f500674-8a1c-431d-a0b7-69506cd47261" />


---

## Task 1: Dockerization & Secure CI/CD Pipeline

The application code is provided in the repository. Your first task is to containerize it and build a secure delivery pipeline.

1. **Dockerize the Application:**
   - Create an **optimal** `Dockerfile` for the provided Python application.
   - Keep the image size as small as possible while ensuring the application runs correctly.
   - Follow container security best practices (e.g., use a minimal base image, run as a non-root user).
2. **Multi-Branch Secure CI/CD Architecture (GitHub Actions or similar):**
   - **Branch Protection:** Enforce a policy where direct commits to the `main` branch are restricted. All changes must go through a Pull Request.
   - **Working Branch Pipeline:** Create a pipeline that is triggered only when a Pull Request is opened against the main branch.
     - It should build and test the image.
     - Integrate code quality and security scanning tools: **Code Linting** (e.g., Flake8), **Secret Scanning** (Optional), **SAST** (Static Application Security Testing(ignore "0.0.0.0" related errors)), Unit test case(pytest) and **Container Image Vulnerability Scanning**.
     - All tests, linting, and security scans must pass successfully before the Pull Request can be merged into main branch.
   - **Release Pipeline (`main` branch):** Create a second pipeline that only triggers when a PR is merged into `main`.
     - This pipeline should build the final images, push them to a container registry (e.g., Docker Hub, GHCR), and automatically update the image tags in the Kubernetes deployment manifests in your repository.

---

## Task 2: GitOps Deployment with ArgoCD

We use GitOps to manage our Kubernetes clusters. You need to automate the deployment of the image you just pushed.

1. **ArgoCD Setup:**
   - Install and configure ArgoCD on your local Kubernetes cluster.
2. **Kubernetes Manifests:**
   - Since your pipeline builds multiple image versions, you must run them simultaneously in your cluster. Create **three separate Deployments** (one for each image version built by your matrix).
   - Create a **single shared Kubernetes Service** that acts as a load balancer to route traffic evenly across all three Deployments.
   - **Crucial:** Since the application has a known memory leak (designed to reach 500MB over 2 minutes), you must configure **Resource Requests and Limits** for all Pods. Set the memory limit explicitly to `400Mi` so that the Kubernetes scheduler terminates the pod (`OOMKilled`) well before it consumes node resources.
3. **Automated Deployment & Image Updates:**
   - Configure ArgoCD to track your repository and automatically deploy/sync the application.
   - You may choose **any method** to automate the updating of the image tag in your deployment environment. For example, you could configure your CI/CD pipeline to automatically commit and push the new image tag back to your Git configuration files after a successful build.
4. **Enterprise Best Practices & Innovation:**
   - Instead of just a basic deployment, design and implement a production-grade Kubernetes footprint using your own innovation. 
   - You must implement at least the following, but you have full creative freedom on how to securely configure them: **Namespaces**, **ConfigMaps & Secrets**, **initContainers**, **RBAC** (ServiceAccounts, Roles), **NetworkPolicies**, and **ResourceQuotas**.

---

## Task 3: Observability, Logging, & Alerting

Visibility into the cluster and the application's behavior is critical.

1. **Comprehensive Observability Stack:**
   - Install **Prometheus** and **Grafana** in your cluster(via Helm) for metrics monitoring.
   - Build a comprehensive Grafana Dashboard that displays (You Can also import them):
     - **Node Metrics:** CPU, Memory, and Disk usage.
     - **Pod & Cluster Metrics:** CPU and Memory usage per pod.
   - **Log Aggregation / Tracing:** Since Prometheus only handles metrics, you must implement an additional observability stack of your choice (e.g., ELK/EFK stack, Loki, or similar) to capture and aggregate the application logs centrally.
2. **Alerting:**
   - Configure **Grafana Alerts** to trigger notifications for the following scenarios:
     - **Application Health Check Failures** (Pod goes down or becomes unready).
     - **OOMKilled Events** (Triggered when the application hits its memory limit).
   - *Bonus:* Route these alerts to a Slack webhook or an email address.

---

## Evaluation Criteria

- **Security Posture:** Quality of the Dockerfile and thoroughness of the CI/CD security gates.
- **GitOps Implementation:** A working ArgoCD setup that successfully detects and deploys changes.
- **Kubernetes Expertise:** Correct implementation of resource limits ensuring the `OOMKilled` behavior occurs as intended.
- **Observability:** A functional, well-designed Grafana dashboard.
- **Reliability Engineering:** Accurate and functional alerting rules for health checks and OOM limits.

---

## Results

**ARGO-CD UI**

<img width="1852" height="925" alt="argocd UI" src="https://github.com/user-attachments/assets/5c3f4230-ded6-4cc6-9f4a-84e51fa42725" />


**LOKI-STREAMS-OF-LOGS**

<img width="1856" height="920" alt="grafana-loki-logs" src="https://github.com/user-attachments/assets/5b2b5d8e-a583-4a0d-9be4-257d44fb2964" />


**LOKI-GRAFANA-PANEL-VISs**

<img width="1857" height="922" alt="loki-logs-visuals" src="https://github.com/user-attachments/assets/eaf43a89-9392-42c0-8fc0-64a601c29ddb" />


**PROMETHEUS-GARFANA-PANEL-VISs**

<img width="1843" height="929" alt="prometheus-grafan-metrics" src="https://github.com/user-attachments/assets/fa27e49f-9352-402f-aff3-6af55108b700" />

**NODE-EXPORTER-METRICS**

<img width="1805" height="921" alt="grafans-ow" src="https://github.com/user-attachments/assets/fc5aaed0-bb36-461f-b878-95d5cf56ddfd" />


**OOM-KILLED-FIRING**

<img width="1150" height="585" alt="alertin-firing-on-grafana" src="https://github.com/user-attachments/assets/ccbaf4c8-ce7d-48c1-84f3-481954667bc1" />

<img width="1170" height="822" alt="alert-rules" src="https://github.com/user-attachments/assets/c3de7b7b-a391-45aa-bbb0-0f20772967e0" />


**APP-HEALTH-CHECKS-FAILURES**

<img width="1168" height="845" alt="Poddown" src="https://github.com/user-attachments/assets/83c1dbcf-eb5d-49cd-a2e6-8d0778caf4f1" />
