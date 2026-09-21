data "aws_iam_policy_document" "lambda_trust" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "remediator" {
  count              = var.enable_apply ? 1 : 0
  name               = "${var.lambda_name}-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_trust.json
}

data "aws_iam_policy_document" "remediator_policy" {
  statement {
    sid    = "S3AclRemediation"
    effect = "Allow"

    actions = [
      "s3:GetBucketAcl",
      "s3:PutBucketAcl"
    ]

    resources = ["arn:aws:s3:::*"]
  }

  statement {
    sid    = "LogsWrite"
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_policy" "remediator" {
  count  = var.enable_apply ? 1 : 0
  name   = "${var.lambda_name}-policy"
  policy = data.aws_iam_policy_document.remediator_policy.json
}

resource "aws_iam_role_policy_attachment" "remediator" {
  count      = var.enable_apply ? 1 : 0
  role       = aws_iam_role.remediator[0].name
  policy_arn = aws_iam_policy.remediator[0].arn
}
