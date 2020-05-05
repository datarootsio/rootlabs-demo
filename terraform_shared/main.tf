provider "google" {
  project = "dataroots-dns"
  region  = "europe-west1"
}

provider "aws" {
  region = "eu-west-1"
}

provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.12"

  backend "s3" {
    encrypt        = true
    bucket         = "dataroots-terraform-states"
    region         = "eu-west-1"
    dynamodb_table = "dataroots-terraform-states-lock"
    key            = "rootlabs-iac/shared.tfsate"
  }
}