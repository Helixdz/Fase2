# Game Server Monitoring — DevOps Infrastructure

Grafana + Prometheus monitoring stack for video game servers, deployed on AWS EKS using Terraform, Docker, Helm, and GitHub Actions CI/CD.

---

## Architecture

```
GitHub PR merged → GitHub Actions CI → Build Docker images → Push to ECR
                → GitHub Actions CD → Helm upgrade → EKS cluster
                                                         ├── Grafana (LoadBalancer)
                                                         └── Prometheus (ClusterIP)
```

---

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) ≥ 1.3
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) configured (`aws configure`)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Helm](https://helm.sh/docs/intro/install/) ≥ 3.14
- An AWS account with permissions to create EKS, ECR, VPC, IAM resources

---

## Step 1 — Provision Infrastructure with Terraform

```bash
cd terraform

# Initialize providers and modules
terraform init

# Preview what will be created
terraform plan -var="github_repo=YOUR_GITHUB_USERNAME/YOUR_REPO_NAME"

# Apply (takes ~15 min for EKS)
terraform apply -var="github_repo=YOUR_GITHUB_USERNAME/YOUR_REPO_NAME"
```

After apply, note the outputs — you'll need them for GitHub secrets:

```
ecr_grafana_url         → ECR_GRAFANA_REPO secret
ecr_prometheus_url      → ECR_PROMETHEUS_REPO secret
eks_cluster_name        → EKS_CLUSTER_NAME secret
github_actions_role_arn → AWS_ROLE_ARN secret
```

---

## Step 2 — Add GitHub Actions Secrets

In your GitHub repo → Settings → Secrets and variables → Actions, add:

| Secret name            | Value                                      |
|------------------------|--------------------------------------------|
| `AWS_ROLE_ARN`         | From terraform output `github_actions_role_arn` |
| `ECR_GRAFANA_REPO`     | From terraform output `ecr_grafana_url` (just the path after the registry, e.g. `gameserver-monitoring/grafana`) |
| `ECR_PROMETHEUS_REPO`  | From terraform output `ecr_prometheus_url` |
| `EKS_CLUSTER_NAME`     | From terraform output `eks_cluster_name`  |
| `GRAFANA_ADMIN_PASSWORD` | A strong password of your choice          |

---

## Step 3 — How CI/CD Works

### CI (on every push or PR to main/master)
1. Authenticates to AWS via OIDC (no stored credentials)
2. Builds `docker/grafana/Dockerfile` and `docker/prometheus/Dockerfile`
3. Tags images with the Git commit SHA and `latest`
4. Pushes both images to ECR

### CD (when a PR is merged into main/master)
1. Authenticates to AWS, gets EKS kubeconfig
2. Runs `helm upgrade --install` with the new image tags
3. Waits for rollout to complete
4. Prints the Grafana LoadBalancer URL

---

## Step 4 — Access Grafana

After a successful deploy:

```bash
# Get the LoadBalancer hostname
kubectl get svc grafana-service -n monitoring

# Login: admin / your GRAFANA_ADMIN_PASSWORD secret
```

---

## Project Structure

```
.
├── terraform/                  # AWS infrastructure (VPC, EKS, ECR, IAM)
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── docker/
│   ├── grafana/                # Custom Grafana image + provisioning
│   │   ├── Dockerfile
│   │   └── provisioning/
│   └── prometheus/             # Custom Prometheus image + scrape config
│       ├── Dockerfile
│       └── prometheus.yml
├── helm/
│   └── gameserver-monitoring/  # Custom Helm chart
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
└── .github/workflows/
    ├── ci.yml                  # Build + push images
    └── cd.yml                  # Deploy to EKS on PR merge
```

---

## Customizing Game Server Scraping

To have Prometheus scrape your game server pods, add these annotations to your game server pod specs:

```yaml
annotations:
  prometheus.io/scrape: "true"
  prometheus.io/port: "YOUR_METRICS_PORT"
  prometheus.io/path: "/metrics"
```

---

## Teardown

```bash
# Remove Helm release
helm uninstall gameserver-monitoring -n monitoring

# Destroy all AWS infrastructure
cd terraform && terraform destroy
```
