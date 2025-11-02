locals {
  lambda_functions = {
    s3_remediation  = "s3_remediation.py"
    sg_remediation  = "sg_remediation.py"
    ebs_remediation = "ebs_remediation.py"
    iam_remediation = "iam_remediation.py"
  }
}

# Zip and create Lambda functions
resource "null_resource" "zip_lambdas" {
  provisioner "local-exec" {
    command = "cd ../lambda && for f in *.py; do zip -r9 ${f%.py}.zip $f; done"
  }
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_basic_execution"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "remediations" {
  for_each         = local.lambda_functions
  filename         = "../lambda/${each.key}.zip"
  function_name    = each.key
  role             = aws_iam_role.lambda_role.arn
  handler          = "${each.key}.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = filebase64sha256("../lambda/${each.key}.zip")

  depends_on = [null_resource.zip_lambdas]
}