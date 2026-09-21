resource "aws_cloudwatch_event_rule" "s3_access_changes" {
  count = var.enable_apply ? 1 : 0
  name  = "s3_access_changes"

  event_pattern = jsonencode({
    source      = ["aws.s3"]
    detail-type = ["AWS API Call via CloudTrail"]

    detail = {
      eventSource = ["s3.amazonaws.com"]
      eventName   = ["PutBucketAcl", "PutBucketPolicy"]
    }
  })
}

resource "aws_cloudwatch_event_target" "remediator" {
  count = var.enable_apply ? 1 : 0
  rule  = aws_cloudwatch_event_rule.s3_access_changes[0].name
  arn   = aws_lambda_function.remediator[0].arn
}

resource "aws_lambda_permission" "allow_events" {
  count         = var.enable_apply ? 1 : 0
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.remediator[0].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.s3_access_changes[0].arn
}
