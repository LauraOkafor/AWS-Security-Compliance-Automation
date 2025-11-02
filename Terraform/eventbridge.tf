locals {
  config_rules = {
    s3_remediation  = "S3_PUBLIC_ACCESS_DISABLED"
    sg_remediation  = "INCOMING_SSH_DISABLED"
    ebs_remediation = "EBS_ENCRYPTION_ENABLED"
    iam_remediation = "IAM_ADMIN_LIMIT"
  }
}

resource "aws_cloudwatch_event_rule" "remediation_rules" {
  for_each    = local.config_rules
  name        = "${each.key}-rule"
  description = "Trigger ${each.key} Lambda"
  event_pattern = jsonencode({
    "source" : ["aws.config"],
    "detail-type" : ["Config Rules Compliance Change"],
    "detail" : {
      "configRuleName" : [each.value],
      "newEvaluationResult" : {
        "complianceType" : ["NON_COMPLIANT"]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "lambda_targets" {
  for_each = local.config_rules
  rule     = aws_cloudwatch_event_rule.remediation_rules[each.key].name
  arn      = aws_lambda_function.remediations[each.key].arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  for_each      = local.config_rules
  statement_id  = "AllowExecutionFromEventBridge-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.remediations[each.key].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.remediation_rules[each.key].arn
}