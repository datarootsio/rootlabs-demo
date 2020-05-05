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

resource "aws_security_group" "to_internal_traffic" {
  name        = "to_internal_traffic"
  description = "Allow LB to contact internal resources"
  vpc_id      = aws_vpc.main.id

  egress {
    description = "Internal access from LB"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.100.0.0/16"]
  }

  tags = {
    Name = "to_internal_traffic"
  }
}

resource "aws_lb" "rootlabs_iac" {
  name               = "rootlabs-iac"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.https_from_any.id, aws_security_group.to_internal_traffic.id]
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