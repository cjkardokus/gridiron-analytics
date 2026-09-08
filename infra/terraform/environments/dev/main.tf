# Dev environment configuration for gridiron-analytics.
#
# This config is a scaffold: no resources are defined yet. It exists to
# prove the remote-state wiring is correct. Real resources (Aurora,
# networking, etc.) are added in later branches.

terraform {
  backend "s3" {
    # Placeholder values only - fill these in after `terraform apply` has
    # actually been run against infra/terraform/bootstrap/ and the state
    # bucket exists for real. Do NOT invent a real bucket name here.
    bucket = "REPLACE_ME_WITH_BOOTSTRAP_STATE_BUCKET_NAME"
    key    = "environments/dev/terraform.tfstate"
    region = "us-west-2"
  }
}
