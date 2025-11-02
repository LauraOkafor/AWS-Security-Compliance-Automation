resource "aws_sns_topic" "remediation_alerts" {
  name = "remediation-alerts"
}

resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.remediation_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_lambda_permission" "sns_permission" {
  for_each      = aws_lambda_function.remediations
  statement_id  = "AllowSNSTrigger-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = each.value.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.remediation_alerts.arn
}