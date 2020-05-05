resource "aws_ecr_repository" "rootlabs_iac" {
  name                 = "rootlabs-iac"
  image_tag_mutability = "MUTABLE"
}