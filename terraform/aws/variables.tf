variable "region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region used for the security controls demo."
}

variable "enable_apply" {
  type        = bool
  default     = false
  description = "Controls whether AWS resources are created for the demo."
}

variable "lambda_name" {
  type        = string
  default     = "controls-demo-remediator"
  description = "Name of the S3 ACL remediation Lambda function."
}

variable "block_public_acls" {
  type        = bool
  default     = true
  description = "Controls whether new public S3 ACLs are blocked at the account level."
}

variable "block_public_policy" {
  type        = bool
  default     = true
  description = "Controls whether new public S3 bucket policies are blocked at the account level."
}
