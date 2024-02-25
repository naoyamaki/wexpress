resource "aws_security_group" "wexpress-db" {
  name = "${var.environment}-${var.service-name}-db"
  vpc_id = aws_vpc.wexpress.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = ["${aws_security_group.service.id}"]
  }
  tags = {
    Name = "${var.environment}-${var.service-name}-db"
  }
}

resource "aws_db_subnet_group" "wexpress" {
  name = "${var.environment}-${var.service-name}"
  subnet_ids = [aws_subnet.db-1c.id, aws_subnet.db-1d.id]
  tags = {
    Name = "${var.environment}-${var.service-name}"
  }
}
resource "aws_db_option_group" "wexpress" {
  name = "${var.environment}-${var.service-name}"
  engine_name              = "aurora-mysql"
  major_engine_version     = "8.0"
}
resource "aws_rds_cluster_parameter_group" "wexpress" {
  name = "${var.environment}-${var.service-name}"
  family      = "aurora-mysql8.0"
  parameter {
    name  = "time_zone"
    value = "Asia/Tokyo"
  }
  parameter {
    name  = "sql_mode"
    value = "TRADITIONAL,NO_AUTO_VALUE_ON_ZERO"
  }
  tags = {
    Name    = "${var.environment}-${var.service-name}"
  }
}
resource "aws_db_parameter_group" "wexpress" {
  name = "${var.environment}-${var.service-name}"
  family = "aurora-mysql8.0"
  tags = {
    Name    = "${var.environment}-${var.service-name}"
  }
}

resource "aws_kms_key" "wexpress-db" {
  tags = {
    Name    = "${var.environment}-${var.service-name}"
  }
}

resource "aws_rds_cluster" "wexpress" {
  cluster_identifier               = "${var.environment}-${var.service-name}"
  engine                           = "aurora-mysql"
  engine_mode                     = "provisioned"
  engine_version                   = "8.0.mysql_aurora.3.05.0"
  db_cluster_parameter_group_name  = aws_rds_cluster_parameter_group.wexpress.name
  db_subnet_group_name             = aws_db_subnet_group.wexpress.name
  availability_zones               = ["ap-northeast-1c", "ap-northeast-1d"]
  vpc_security_group_ids           = [aws_security_group.wexpress-db.id]
  database_name             = var.service-name
  master_username           = var.db-user
  master_password           = var.db-password
  apply_immediately         = true
  backup_retention_period   = 1
  preferred_backup_window   = "14:00-15:00"
  copy_tags_to_snapshot     = true
  storage_encrypted         = true
  kms_key_id                = aws_kms_key.wexpress-db.arn
  deletion_protection       = false
  final_snapshot_identifier = "${var.environment}-${formatdate("YYYYMMDDhhmm", timestamp())}"
  serverlessv2_scaling_configuration {
    min_capacity = var.aurora-min-capacity
    max_capacity = var.aurora-max-capacity
  }
  tags = {
    Name    = "${var.environment}-${var.service-name}"
  }
  lifecycle {
    ignore_changes = [availability_zones, final_snapshot_identifier]
  }
}

resource "aws_rds_cluster_instance" "wexpress" {
  count = var.aurora-count
  cluster_identifier = aws_rds_cluster.wexpress.id
  identifier                 = "${var.environment}-${var.service-name}-${format("%02d", count.index + 1)}"
  engine                     = aws_rds_cluster.wexpress.engine
  engine_version             = aws_rds_cluster.wexpress.engine_version
  instance_class             = "db.serverless"
  db_subnet_group_name       = aws_db_subnet_group.wexpress.name
  db_parameter_group_name    = aws_db_parameter_group.wexpress.name
  publicly_accessible        = false
  auto_minor_version_upgrade = false
  tags = {
    Name    = "${var.environment}-${var.service-name}-${format("%02d", count.index + 1)}"
  }
}
