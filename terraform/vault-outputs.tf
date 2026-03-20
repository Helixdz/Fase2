# Add these to your existing outputs.tf

output "vault_public_ip" {
  description = "Public IP of the Vault EC2 instance"
  value       = aws_eip.vault.public_ip
}

output "vault_ui_url" {
  description = "Vault UI URL"
  value       = "http://${aws_eip.vault.public_ip}:8200/ui"
}
