data "aws_caller_identity" "current" {}

data "aws_route53_zone" "external" {
  name = var.route53_zone
}

data "aws_iam_role" "ecs_role" {
  name = "ecsTaskExecutionRole"

}


resource "aws_ecr_repository" "abc-ecr" {
  name                 = var.repo_name
  image_tag_mutability = "IMMUTABLE"
}


#######
resource "aws_security_group" "alb_sg" {
  name   = var.alb_name
  vpc_id = var.vpc_id

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = var.alb_name
  }
}

resource "aws_lb" "ecs_alb" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnets

  enable_deletion_protection = false
}



resource "aws_alb_target_group" "ecs_alb_target_group" {
  name        = var.target_group_name
  port        = var.service_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/"
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    unhealthy_threshold = "2"
  }
}


resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      host        = "${var.domain}"
      port        = "80"
      protocol    = "HTTP"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "web_https" {
  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn = aws_acm_certificate.cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.ecs_alb_target_group.arn
  }
}

resource "aws_lb_listener_rule" "static" {
  listener_arn = aws_lb_listener.web_https.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn =aws_alb_target_group.ecs_alb_target_group.arn
  }


  condition {
    host_header {
      values = [var.domain]
    }
  }
}


resource "aws_security_group" "ecs_task_sg" {
  name   = var.ecs_service_sg_name
  vpc_id = var.vpc_id

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.vpc_cidr]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = ["${aws_security_group.alb_sg.id}"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = var.ecs_service_sg_name
  }
}


resource "aws_acm_certificate" "cert" {
  domain_name       = var.domain
  validation_method = "DNS"
}

resource "aws_route53_record" "validation" {
  name    =tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_type
  zone_id = data.aws_route53_zone.external.zone_id
  records = [ tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_value ]
  ttl     = "60"
}