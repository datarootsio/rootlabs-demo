provider "aws" {
  region = "eu-west-1"
}

terraform {
  required_version = ">= 0.12"

  backend "s3" {
    encrypt        = true
    bucket         = "dataroots-terraform-states"
    region         = "eu-west-1"
    dynamodb_table = "dataroots-terraform-states-lock"
  }
}

data "terraform_remote_state" "shared" {
  backend = "s3"
  config = {
    bucket = "dataroots-terraform-states"
    region = "eu-west-1"
    key    = "rootlabs-iac/shared.tfsate"
  }
}