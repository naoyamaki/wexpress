resource "aws_efs_file_system" "wexpress" {
  throughput_mode = "elastic"
  tags = {
    Name = "${var.environment}-${var.service-name}"
  }
}
resource "aws_efs_mount_target" "wexpress-1c" {
  file_system_id = aws_efs_file_system.wexpress.id
  subnet_id      = aws_subnet.pri-1c.id
}
resource "aws_efs_mount_target" "wexpress-1d" {
  file_system_id = aws_efs_file_system.wexpress.id
  subnet_id      = aws_subnet.pri-1d.id
}
resource "aws_security_group" "efs" {
  name   = "${var.environment}-${var.service-name}-efs"
  vpc_id = aws_vpc.wexpress.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # ingress {
  #   from_port       = 2049
  #   to_port         = 2049
  #   protocol        = "tcp"
  #   security_groups = ["${aws_security_group.service-sg.id}"]
  # }
  tags = {
    Name = "${var.environment}-${var.service-name}-efs"
  }
}

resource "aws_s3_bucket" "alb-log" {
  bucket = "${var.environment}-${var.service-name}-alb-log"

  tags = {
    Name = "${var.environment}-${var.service-name}-alb-log"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "alb-log" {
  bucket = aws_s3_bucket.alb-log.id
  rule {
    id = "delete_1year"
    expiration {
      days = 30
    }
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "wexpress-log" {
  bucket = "${var.environment}-${var.service-name}-wexpress-log"

  tags = {
    Name = "${var.environment}-${var.service-name}-wexpress-log"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "wexpress-log" {
  bucket = aws_s3_bucket.wexpress-log.id
  rule {
    id = "delete_1year"
    expiration {
      days = 30
    }
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "wexpress-static" {
  bucket = "${var.environment}-${var.service-name}-static"
  tags = {
    Name    = "${var.environment}-${var.service-name}-static"
  }
}
resource "aws_s3_bucket_policy" "wexpress-static" {
  bucket = aws_s3_bucket.wexpress-static.id
  policy = templatefile("./policy/static-bucket-policy.json", {
    this_bucket_arn = aws_s3_bucket.wexpress-static.arn
    cloudfront_arn  = "*"
  })
}
