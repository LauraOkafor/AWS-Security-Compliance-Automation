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