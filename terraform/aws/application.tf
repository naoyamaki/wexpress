resource "aws_lb" "wexpress" {
  name               = "${var.environment}-${var.service-name}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets = [
    aws_subnet.pub-1c.id,
    aws_subnet.pub-1d.id
  ]
  access_logs {
    bucket  = aws_s3_bucket.alb-log.bucket
    enabled = true
  }
  idle_timeout               = 60
  desync_mitigation_mode     = "defensive"
  xff_header_processing_mode = "append"
  enable_deletion_protection = false
  tags = {
    Name    = "${var.environment}-${var.service-name}"
  }
}

resource "aws_lb_listener" "wexpress" {
  load_balancer_arn = aws_lb.wexpress.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.wexpress.arn

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
      host        = var.domain-name
    }
  }
  tags = {
    Name    = "${var.environment}-${var.service-name}"
  }
}

resource "aws_lb_listener_rule" "wexpress" {
  listener_arn = aws_lb_listener.wexpress.arn
  priority     = 1
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wexpress.arn
  }
  condition {
    host_header {
      values = [var.domain-name]
    }
  }
  tags = {
    Name    = "${var.environment}-${var.service-name}"
  }
}

resource "aws_lb_target_group" "wexpress" {
  name        = "${var.environment}-${var.service-name}"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.wexpress.id
  deregistration_delay = "60"
  health_check {
    interval            = 30
    path                = "/wp-login.php"
    port                = 80
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
    healthy_threshold   = 2
    matcher             = 200
  }
  tags = {
    Name    = "${var.environment}-${var.service-name}"
  }
}

resource "aws_security_group" "alb" {
  name   = "${var.environment}-${var.service-name}-alb"
  vpc_id = aws_vpc.wexpress.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "open"
  }
  tags = {
    Name    = "${var.environment}-${var.service-name}"
  }
}
resource "aws_security_group" "service" {
  name   = "${var.environment}-${var.service-name}-service"
  vpc_id = aws_vpc.wexpress.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.alb.id}"]
  }
  tags = {
    Name    = "${var.environment}-${var.service-name}"
  }
}

resource "aws_ecs_task_definition" "wexpress" {
  family                   = "wexpress"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "2048"
  network_mode             = "awsvpc"

  container_definitions = templatefile("./task-definition/wexpress.json", {
    # TODO: コンテナイメージのタグを暫定でlatestにしているため、正式なものが確定したら修正.
    wexpress_image        = "${aws_ecr_repository.wexpress-app.repository_url}:latest"
    log_router_image = "${aws_ecr_repository.wexpress-log-router.repository_url}:latest"
    log_bucket                 = aws_s3_bucket.wexpress-log.bucket
  })

  volume {
    efs_volume_configuration {
      authorization_config { iam = "DISABLED" }
      file_system_id          = aws_efs_file_system.wexpress.id
      root_directory          = "/"
      transit_encryption      = "DISABLED"
      transit_encryption_port = "0"
    }
    name = "wordpress"
 }
  tags = {
    Name    = "${var.environment}-${var.service-name}"
  }
}
resource "aws_ecs_cluster" "wexpress" {
  name               = "wexpress"

  setting {
    name  = "containerInsights"
    value = "disabled"
  }
  tags = {
    Name    = "${var.environment}-${var.service-name}"
  }
}
resource "aws_ecs_service" "wexpress" {
 cluster                            = aws_ecs_cluster.wexpress.name
 name                               = "wexpress"
 platform_version                   = "1.4.0"
 scheduling_strategy                = "REPLICA"
 deployment_maximum_percent         = "200"
 deployment_minimum_healthy_percent = "100"
 desired_count                      = "2"
 enable_ecs_managed_tags            = "true"
 enable_execute_command             = "true"
 health_check_grace_period_seconds  = "30"
 launch_type                        = "FARGATE"
 task_definition                    = aws_ecs_task_definition.wexpress.arn

 load_balancer {
   container_name   = "web"
   container_port   = "80"
   target_group_arn = aws_lb_target_group.wexpress.arn
 }
 network_configuration {
   assign_public_ip = "true"
   security_groups  = ["${aws_security_group.service.id}"]
   subnets          = ["${aws_subnet.public-a.id}", "${aws_subnet.public-c.id}"]
 }
  tags = {
    Name    = "${var.environment}-${var.service-name}"
  }
}
