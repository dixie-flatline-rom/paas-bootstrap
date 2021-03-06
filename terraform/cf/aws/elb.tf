resource "aws_elb" "cf-ssh-lb" {
  name                      = "${var.environment}-cf-ssh-lb"
  internal                  = false
  subnets                   = ["${data.aws_subnet_ids.public.ids}"]
  cross_zone_load_balancing = "true"

  security_groups = ["${aws_security_group.cf_ssh_lb.id}"]

  health_check {
    target              = "TCP:2222"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
  }

  listener {
    instance_port     = 2222
    instance_protocol = "tcp"
    lb_port           = 2222
    lb_protocol       = "tcp"
  }

  tags {
    Name        = "${var.environment}-cf-ssh-lb"
    Environment = "${var.environment}"
  }

  lifecycle {
    create_before_destroy = true
  }
}
