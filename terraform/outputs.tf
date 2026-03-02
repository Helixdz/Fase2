output "ecr_grafana_url" {
  description = "ECR URL for Grafana image"
  value       = aws_ecr_repository.grafana.repository_url
}

output "ecr_prometheus_url" {
  description = "ECR URL for Prometheus image"
  value       = aws_ecr_repository.prometheus.repository_url
}

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = module.eks.cluster_endpoint
}

output "github_actions_role_arn" {
  description = "IAM role ARN for GitHub Actions (add this to GitHub secrets as AWS_ROLE_ARN)"
  value       = aws_iam_role.github_actions.arn
}
