# ─── Vault EC2 Instance ─────────────────────────────────────────────────────
# Add this to your existing main.tf, or apply separately

# Security group for Vault
resource "aws_security_group" "vault" {
  name        = "${var.project_name}-vault-sg"
  description = "Allow Vault UI and API access"
  vpc_id      = module.vpc.vpc_id

  # Vault API + UI
  ingress {
    from_port   = 8200
    to_port     = 8200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH for Ansible
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

# Key pair for SSH access (Ansible needs this)
resource "aws_key_pair" "vault" {
  key_name   = "${var.project_name}-vault-key"
  public_key = file(var.vault_ssh_public_key_path)

  tags = var.tags
}

# Latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# EC2 instance for Vault (t2.micro = free tier eligible)
resource "aws_instance" "vault" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t2.micro"
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.vault.id]
  key_name                    = aws_key_pair.vault.key_name
  associate_public_ip_address = true

  tags = merge(var.tags, {
    Name = "${var.project_name}-vault"
  })
}

# Elastic IP so the address doesn't change on reboot
resource "aws_eip" "vault" {
  instance = aws_instance.vault.id
  domain   = "vpc"
  tags     = var.tags
}
