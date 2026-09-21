resource "aws_s3_account_public_access_block" "this" {
  count                   = var.enable_apply ? 1 : 0
  block_public_acls       = var.block_public_acls
  ignore_public_acls      = true
  block_public_policy     = var.block_public_policy
  restrict_public_buckets = true
}
