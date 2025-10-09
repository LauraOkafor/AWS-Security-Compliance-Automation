output "ec2_public_ip" {
  value = aws_instance.web.public_ip
}

output "s3_bucket_name" {
  value = aws_s3_bucket.logs.bucket
}


output "ssh_key_path" {
  value = "~/.ssh/your-key.pem"
}