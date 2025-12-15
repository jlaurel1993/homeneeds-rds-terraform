# ============================================================
#  HomeNeedsService RDS Deployment - main.tf (FINAL)
# ============================================================

# --- 1️⃣ Discover your current public IP for MySQL ingress
data "http" "myip" {
  url = "https://checkip.amazonaws.com"
}

# --- 2️⃣ Build a valid CIDR block from your public IP
locals {
  my_ip_cidr = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}$", chomp(data.http.myip.response_body))) ? "${chomp(data.http.myip.response_body)}/32" : var.allow_cidr
}

# --- 3️⃣ Use the default VPC (simplest for dev)
data "aws_vpc" "default" {
  default = true
}

# --- 4️⃣ Grab all default subnets (for RDS placement)
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# --- 5️⃣ Security group allowing MySQL from your IP only
resource "aws_security_group" "rds_sg" {
  name        = "homeneeds-rds-sg"
  description = "MySQL access for HomeNeedsService"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Allow MySQL from my IP"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [local.my_ip_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "homeneeds-rds-sg"
  }
}

# --- 6️⃣ RDS Subnet Group
resource "aws_db_subnet_group" "this" {
  name       = "homeneeds-db-subnets"
  subnet_ids = data.aws_subnets.default.ids

  tags = {
    Name = "homeneeds-db-subnets"
  }
}

# --- 7️⃣ MySQL Parameter Group (fixed apply_method)
resource "aws_db_parameter_group" "mysql_params" {
  name        = "homeneeds-mysql-params"
  family      = "mysql8.0"
  description = "Parameter group for HomeNeedsService MySQL 8.0"

  parameter {
    name         = "performance_schema"
    value        = "1"
    apply_method = "pending-reboot"
  }

  tags = {
    Name = "homeneeds-mysql-params"
  }
}

# --- 8️⃣ Create the RDS instance
resource "aws_db_instance" "mysql" {
  identifier        = "homeneeds-db"
  engine            = "mysql"
  engine_version    = "8.0"
  db_name           = var.db_name
  instance_class    = "db.t3.micro" # free-tier eligible
  allocated_storage = 20
  storage_type      = "gp3"

  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  publicly_accessible          = var.public_access
  skip_final_snapshot          = true
  deletion_protection          = false
  backup_retention_period      = 7
  performance_insights_enabled = false
  parameter_group_name         = aws_db_parameter_group.mysql_params.name

  tags = {
    Project = "HomeNeedsService"
    Env     = "dev"
  }
}
