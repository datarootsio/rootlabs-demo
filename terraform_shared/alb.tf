resource "aws_security_group" "https_from_any" {
  name        = "https_from_any"
  description = "Allow HTTPS inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTPS From any"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "https_from_any"
  }
}

resource "aws_lb" "rootlabs_iac" {
  name               = "rootlabs-iac"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.https_from_any.id]
  subnets            = aws_subnet.public.*.id

  enable_deletion_protection = true
}

resource "aws_lb_listener" "rootlabs_iac" {
  load_balancer_arn = aws_lb.rootlabs_iac.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = aws_acm_certificate.cert.arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "NOT FOUND"
      status_code  = "404"
    }
  }
}

resource "google_dns_record_set" "rootlabs_alb" {
  count = length(var.dns_names)
  name  = "${var.dns_names[count.index]}."
  type  = "CNAME"
  ttl   = 3600

  managed_zone = data.google_dns_managed_zone.dns_zone.name

  rrdatas = ["${aws_lb.rootlabs_iac.dns_name}."]
}