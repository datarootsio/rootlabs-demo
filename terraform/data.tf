data "google_dns_managed_zone" "dns_zone" {
  name = replace(var.domain_name, ".", "-")
}

data "aws_ecr_repository" "rootlabs_iac" {
  name = "rootlabs-iac"
}