
resource "aws_lb" "task-lb" {
  name               = "task-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ALB-sg.id]

  subnets = [aws_subnet.task_subnet1.id, aws_subnet.task_subnet2.id]
}

resource "aws_lb_target_group" "varnish-group" {
  name     = "varnish-group-lb-target"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.task-vpc.id
}

resource "aws_lb_target_group_attachment" "varnish-group" {
  target_group_arn = aws_lb_target_group.varnish-group.arn
  target_id        = aws_instance.varnich_instance.id
  port             = 80
}

resource "aws_lb_target_group" "magento-group" {
  name     = "magento-group-lb-target"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.task-vpc.id
}

resource "aws_lb_target_group_attachment" "magento-group" {
  target_group_arn = aws_lb_target_group.magento-group.arn
  target_id        = aws_instance.magento-instance.id
  port             = 80
}

data "aws_acm_certificate" "issued" {
  domain   = "mhsalameh.com"
  statuses = ["ISSUED"]
}

resource "aws_lb_listener" "http-task-lb" {
  load_balancer_arn = aws_lb.task-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https-task-lb" {
  load_balancer_arn = aws_lb.task-lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = data.aws_acm_certificate.issued.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.varnish-group.arn
  }
}
resource "aws_lb_listener_rule" "static" {
  listener_arn = aws_lb_listener.https-task-lb.arn
  # priority = 100
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.magento-group.arn
  }
  condition {
    path_pattern {
      values = ["/static*", "/media*"]
    }
  }
}
