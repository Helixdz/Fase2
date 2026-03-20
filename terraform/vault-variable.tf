# Add this to your existing variables.tf

variable "vault_ssh_public_key_path" {
  description = "Path to your SSH public key for Vault EC2 access (used by Ansible)"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}
