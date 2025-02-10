resource "aws_vpc" "default" {
  cidr_block           = "10.${var.cidr_numeral}.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-${var.vpc_name}"
  }
}

resource "aws_internet_gateway" "default" {

  vpc_id = aws_vpc.default.id

  tags = {
    Name = "igw-${var.vpc_name}"
  }
}

resource "aws_subnet" "public" {

  count = length(var.availability_zones)
  vpc_id = aws_vpc.default.id

  cidr_block = "10.${var.cidr_numeral}.${var.cidr_numeral_public[count.index]}.0/24"
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name = "public-${count.index}-${var.vpc_name}"
  }
}

resource "aws_route_table" "public" {
  count = length(var.availability_zones)
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "public-${count.index}rt-${var.vpc_name}"
  }
}

resource "aws_route" "public" {
  count = length(var.availability_zones)
  route_table_id = element(aws_route_table.public[*].id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default.id
}

resource "aws_route_table_association" "public" {
  count = length(var.availability_zones)
  subnet_id = element(aws_subnet.public.*.id, count.index)
  route_table_id = element(aws_route_table.public.*.id, count.index)
}

resource "aws_subnet" "private" {
  count = length(var.availability_zones)
  vpc_id = aws_vpc.default.id

  cidr_block = "10.${var.cidr_numeral}.${var.cidr_numeral_private[count.index]}.0/24"
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name = "private-${count.index}-${var.vpc_name}"
  }
}

resource "aws_route_table" "private" {
  count = length(var.availability_zones)
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "private-${count.index}rt-${var.vpc_name}"
  }
}

resource "aws_route_table_association" "private" {
  count = length(var.availability_zones)
  subnet_id = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

resource "aws_subnet" "private_db" {
  count = length(var.availability_zones)
  vpc_id = aws_vpc.default.id

  cidr_block = "10.${var.cidr_numeral}.${var.cidr_numeral_private_db[count.index]}.0/24"
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name = "db-private-${count.index}-${var.vpc_name}"
  }
}

resource "aws_route_table" "private_db" {
  count = length(var.availability_zones)
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "db-private-${count.index}rt-${var.vpc_name}"
  }
}

resource "aws_route_table_association" "private_db" {
  count = length(var.availability_zones)
  subnet_id = element(aws_subnet.private_db.*.id, count.index)
  route_table_id = element(aws_route_table.private_db.*.id, count.index)
}

resource "aws_security_group" "alb" {
  vpc_id = aws_vpc.default.id

  ingress {
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg-${var.vpc_name}"
  }
}

resource "aws_security_group" "instance" {
  vpc_id = aws_vpc.default.id

  ingress {
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "instance-sg-${var.vpc_name}"
  }
}

resource "aws_launch_template" "default" {
  image_id      = "ami-0efd84ba2d870ac79"
  description   = "Installed Docker and CodeDeploy Agent"
  instance_type = "t2.micro"

  network_interfaces {
    associate_public_ip_address = true
    security_groups = [aws_security_group.instance.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "launch-template-default-${var.vpc_name}"
    }
  }

}

resource "aws_autoscaling_group" "api" {
  name             = "asg-api-${var.vpc_name}"
  max_size         = 2
  min_size         = 1
  desired_capacity = 1
  launch_template {
    id      = aws_launch_template.default.id
    version = "$Latest"
  }
  vpc_zone_identifier = aws_subnet.public[*].id
  target_group_arns = [aws_lb_target_group.api.arn]

  tag {
    key                 = "Name"
    value               = "example-instance"
    propagate_at_launch = true
  }
}

resource "aws_lb" "api" {
  name               = "alb-api-${var.vpc_name}"
  load_balancer_type = "application"
  security_groups = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id
}

resource "aws_lb_target_group" "api" {
  name     = "tg-api-${var.vpc_name}"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.default.id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
  }
}

resource "aws_lb_listener" "api" {
  load_balancer_arn = aws_lb.api.arn
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }
}