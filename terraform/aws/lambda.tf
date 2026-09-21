data "archive_file" "remediator_zip" {
  type        = "zip"
  source_file = "${path.module}/../../functions/s3_public_acl_remediator.py"
  output_path = "${path.module}/.build/remediator.zip"
}

resource "aws_lambda_function" "remediator" {
  count            = var.enable_apply ? 1 : 0
  function_name    = var.lambda_name
  role             = aws_iam_role.remediator[0].arn
  filename         = data.archive_file.remediator_zip.output_path
  source_code_hash = data.archive_file.remediator_zip.output_base64sha256
  handler          = "s3_public_acl_remediator.handler"
  runtime          = "python3.11"
  timeout          = 30
  memory_size      = 256
}
