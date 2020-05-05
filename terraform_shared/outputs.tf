output "ecr_repository_url" {
  value = aws_ecr_repository.rootlabs_iac.repository_url
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnets_ids" {
  value = aws_subnet.public.*.id
}

output "private_subnets_ids" {
  value = aws_subnet.private.*.id
}

output "alb_listener_arn" {
  value = aws_lb_listener.rootlabs_iac.arn
}

output "alb_dns_name" {
  value = aws_lb.rootlabs_iac.dns_name
}

output "egress_security_group" {
  value = aws_security_group.rootlabs_container.id
}