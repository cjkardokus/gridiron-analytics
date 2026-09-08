variable "account_suffix" {
  description = <<-EOT
    Account-specific suffix appended to the state bucket name to keep it
    globally unique (e.g. an AWS account ID or short random string).
    Must be supplied explicitly - no default is provided so a real value
    is never guessed or hardcoded here.
  EOT
  type        = string
}

variable "region" {
  description = "AWS region the bootstrap resources are created in."
  type        = string
  default     = "us-west-2"
}
