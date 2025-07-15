# Runbook: Odyssey Entitlements Service

This runbook provides L2/L3 support engineers with diagnostic and resolution procedures for common alerts related to the Entitlements Service.

---
## 📖 At-a-Glance

| Resource | Link / Command |
| :--- | :--- |
| **Service Owner** | Entitlements Platform Team |
| **Grafana Dashboard** | [Odyssey Service Health](http://localhost:8081) *(via port-forward)* |
| **Source Code** | `https://github.com/your-username/odyssey-entitlements` |
| **Primary On-Call** | `#entitlements-support` on Slack |
| **Check Pod Status** | `kubectl get pods -l app=entitlements-service`|

---
## 🚨 Critical Alerts & Triage Procedures

### 1. Alert: `HighAPILatency`
- **Condition:** 99th percentile API latency is above 500ms for 5 minutes.
- **Impact:** Users are experiencing slow response times, which may lead to timeouts in downstream systems.

#### Triage Steps
1.  **Check the Grafana Dashboard:**
    * Look at the **"Average API Latency"** panel. Is the spike sudden or gradual?
    * Look at the **"API Request Rate"** panel. Does the latency spike correlate with a traffic spike?
    * Look at the **"Spanner In-Use Sessions"** panel. Is database activity unusually high?
2.  **Check Pod Resources:**
    * Look for CPU or Memory throttling on the pods.
        ```bash
        # Check resource usage
        kubectl top pods -l app=entitlements-service
        ```
3.  **Inspect Logs for Slow Operations:**
    * Check the application logs for any warnings or errors that occurred during the time of the latency spike.
        ```bash
        kubectl logs -l app=entitlements-service --tail=200
        ```

#### Remediation
* If a specific pod appears unhealthy or is using excessive resources, a targeted restart can resolve the issue. This is the first-line remediation step.
    ```bash
    # Restart the entire service deployment gracefully
    kubectl rollout restart deployment entitlements-service
    ```

#### Escalation
* If latency remains high after a restart and the cause is not apparent, escalate to the **L3/Dev team** with a link to the Grafana dashboard showing the time window of the incident.

---
### 2. Alert: `HighErrorRate`
- **Condition:** The rate of HTTP 5xx server errors is > 1% for 5 minutes.
- **Impact:** Users are receiving errors. The service is considered degraded or unavailable.

#### Triage Steps
1.  **Check the Grafana Dashboard:**
    * The **"API Error Rate (5xx)"** panel will confirm the incident.
2.  **Get the Exact Error from Logs:**
    * This is the most critical step. The logs will contain the full stack trace of the error.
        ```bash
        # Get logs from all pods matching the service label
        kubectl logs -l app=entitlements-service --tail=200
        ```
    * Look for the Java exception (e.g., `SpannerDataException`, `NullPointerException`).

#### Remediation
* This alert is almost always caused by a code-level or configuration bug. A restart is unlikely to fix the issue permanently. The primary goal is to gather diagnostic information for the development team.

#### Escalation
* Escalate immediately to the **L3/Dev team**. Provide the **full stack trace** from the logs in the ticket.

---
### 3. Alert: `PodCrashLooping`
- **Condition:** A pod has a status of `CrashLoopBackOff`.
- **Impact:** The service has reduced capacity and may be fully unavailable if all pods are crashing.

#### Triage Steps
1.  **Describe the Pod to Find the Reason:**
    * The `describe` command will show the pod's "Events" table, which usually contains the reason for the crash (e.g., `FailedMount`, `ImagePullBackOff`).
        ```bash
        # Get the full name of the crashing pod first
        kubectl get pods -l app=entitlements-service

        # Describe the pod
        kubectl describe pod <pod-name>
        ```
2.  **Check Logs from the Previous Container:**
    * Since the container is crashing, you need the logs from its last run using the `--previous` flag.
        ```bash
        kubectl logs <pod-name> --previous
        ```
    * Look for a fatal error right at the end of the log (e.g., "File does not exist", "Failed to connect to Spanner").

#### Remediation
* **Missing Secret:** If the error is `secret "spanner-credentials" not found`, the secret needs to be created. Escalate to the team with on-call admin access.
* **Bad Image:** If the error is `ErrImagePull` or `ImagePullBackOff`, the Docker image tag in the deployment might be incorrect.

#### Escalation
* Escalate to the **L3/Dev team** with the output of both the `describe pod` and `logs --previous` commands.