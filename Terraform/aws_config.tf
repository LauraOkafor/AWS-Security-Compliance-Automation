resource "aws_s3_bucket" "config_bucket" {
  bucket = "config-logs-${random_id.bucket.hex}"
}

resource "random_id" "bucket" {
  byte_length = 4
}

resource "aws_config_configuration_recorder" "main" {
  name     = "config_recorder"
  role_arn = aws_iam_role.config_role.arn
}

resource "aws_iam_role" "config_role" {
  name = "config_service_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "config.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_config_delivery_channel" "main" {
  name           = "config_channel"
  s3_bucket_name = aws_s3_bucket.config_bucket.bucket
  depends_on     = [aws_config_configuration_recorder.main]
}

resource "aws_config_configuration_recorder_status" "main" {
  name       = aws_config_configuration_recorder.main.name
  is_enabled = true
}