resource "aws_security_group" "rds" {
  vpc_id = var.vpc_id

  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-sg-${var.vpc_name}"
  }
}

resource "aws_db_subnet_group" "private_db" {
  name = "rds-subnet-group-${var.vpc_name}"
  subnet_ids = [var.private_db1, var.private_db2]

  tags = {
    Name = "rds-subnet-group-${var.vpc_name}"
  }
}

resource "aws_db_instance" "rdb" {
  identifier            = "rdb-${var.vpc_name}"
  engine                = "mysql"
  engine_version        = "8.0"
  instance_class        = "db.t3.micro"
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp2"
  username              = var.db_username
  password              = var.db_password
  parameter_group_name  = "default.mysql8.0"
  db_subnet_group_name  = aws_db_subnet_group.private_db.name
  skip_final_snapshot   = true

  tags = {
    Name = "rdb-${var.vpc_name}"
  }
}