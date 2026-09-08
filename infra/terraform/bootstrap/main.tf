# Bootstrap configuration for gridiron-analytics.
#
# This config creates the S3 bucket that the main environments/ configs
# use as their remote state backend. It is a chicken-and-egg problem -
# something has to create the state bucket before remote state can point
# at it - so this config intentionally keeps its OWN state local
# (no backend block) and must continue to do so permanently.
#
# This has not been applied yet. Do not run `terraform apply` until AWS
# credentials are configured outside of source control.

terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "terraform_state" {
  # Bucket names are globally unique across all AWS accounts, so the
  # account-specific suffix is required as a variable rather than
  # hardcoded here.
  bucket = "gridiron-analytics-tfstate-${var.account_suffix}"
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}
