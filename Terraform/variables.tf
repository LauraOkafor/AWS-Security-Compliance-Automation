variable "project_name" {
  default = "security-automation"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "ami_id" {
  # Amazon Linux 2 AMI (update if needed for your region)
  default = "ami-0c55b159cbfafe1f0"
}

variable "key_path" {
  description = "Path to the SSH private key file"
  type        = string
  default     = "~/.ssh/your-key.pem"
}

variable "key_pair_name" {
  description = "Name of existing AWS key pair"
  type        = string
}

variable "alert_email" {
  description = "Email to receive remediation alerts"
  type        = string
}