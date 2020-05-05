
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block           = "10.100.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name  = "main vpc"
    Usage = "Infrastructure"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name  = "main igw"
    Usage = "Infrastructure"
  }
}

resource "aws_security_group" "rootlabs_container" {
  vpc_id      = aws_vpc.main.id
  name        = "rootlabs_container"
  description = "rootlabs_container"
  tags = {
    Name = "rootlabs_container"
  }
}

resource "aws_security_group_rule" "https_in_vpc" {
  security_group_id = aws_security_group.rootlabs_container.id
  type              = "egress"
  protocol          = "TCP"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "dns_in_vpc" {
  security_group_id = aws_security_group.rootlabs_container.id
  type              = "egress"
  protocol          = "UDP"
  from_port         = 53
  to_port           = 53
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "dns_tcp_in_vpc" {
  security_group_id = aws_security_group.rootlabs_container.id
  type              = "egress"
  protocol          = "TCP"
  from_port         = 53
  to_port           = 53
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ingress_from_lb" {
  security_group_id = aws_security_group.rootlabs_container.id
  type              = "ingress"
  protocol          = "TCP"
  from_port         = 8000
  to_port           = 8000
  cidr_blocks       = ["10.100.0.0/16"]
}

resource "aws_subnet" "private" {
  count             = length(data.aws_availability_zones.available.names)
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.100.${count.index}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "private subnet ${data.aws_availability_zones.available.names[count.index]}"
  }
}

resource "aws_subnet" "public" {
  count             = length(data.aws_availability_zones.available.names)
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.100.${count.index + 10}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "public subnet ${data.aws_availability_zones.available.names[count.index]}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Private Route Table"
  }
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public_subnets" {
  count          = length(data.aws_availability_zones.available.names)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_vpc_endpoint" "logs" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.eu-west-1.logs"
  vpc_endpoint_type = "Interface"
  subnet_ids        = aws_subnet.private.*.id

  security_group_ids = [
    aws_security_group.https_from_any.id
  ]

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.eu-west-1.s3"
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.eu-west-1.ecr.api"
  vpc_endpoint_type = "Interface"
  subnet_ids        = aws_subnet.private.*.id

  security_group_ids = [
    aws_security_group.https_from_any.id
  ]

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.eu-west-1.ecr.dkr"
  vpc_endpoint_type = "Interface"
  subnet_ids        = aws_subnet.private.*.id

  security_group_ids = [
    aws_security_group.https_from_any.id
  ]

  private_dns_enabled = true
}