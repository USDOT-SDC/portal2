resource "aws_security_group" "guacamole_lb" {
  name        = "guacamole_lb"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = var.common.vpc.id
  tags        = local.tags
}

resource "aws_vpc_security_group_ingress_rule" "guacamole_lb_allow_tls" {
  security_group_id = aws_security_group.guacamole_lb.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "guacamole_lb_allow_all" {
  security_group_id = aws_security_group.guacamole_lb.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_endpoint_service" "guacamole_es" {
  # This is where public traffic enters the SDC going to the public Guacamole server
  # SDC Route53 --> DOT public IPs --> Transit VPCe --> This VPCse
  # only deploy to prod
  for_each                   = var.common.environment == "prod" ? { "deployed" : {} } : {}
  acceptance_required        = var.common.environment == "prod" ? false : true
  allowed_principals         = ["arn:aws:iam::338629629125:root"]
  network_load_balancer_arns = [aws_lb.guacamole_nlb["deployed"].arn]
  supported_ip_address_types = ["ipv4"]
  tags = merge(
    local.tags,
    {
      Name = "Guacamole ES"
    }
  )
}

resource "aws_lb" "guacamole_nlb" {
  # only deploy to prod
  for_each                         = var.common.environment == "prod" ? { "deployed" : {} } : {}
  name                             = "guacamole-nlb"
  load_balancer_type               = "network"
  internal                         = true
  enable_cross_zone_load_balancing = true
  ip_address_type                  = "ipv4"
  security_groups = [
    aws_security_group.guacamole_lb.id
  ]
  subnets = [
    var.common.vpc.subnet_four.id,
    var.common.vpc.subnet_five.id
  ]
  preserve_host_header = "true"
  access_logs {
    enabled = true
    bucket  = "aws-elb-logs-131321883543"
  }
  tags = merge(
    local.tags,
    {
      Name = "Guacamole NLB"
    }
  )
}

resource "aws_lb" "guacamole_alb" {
  # do not deploy to prod
  for_each           = var.common.environment == "prod" ? {} : { "deployed" : {} }
  name               = "guacamole-alb"
  load_balancer_type = "application"
  internal           = true
  ip_address_type    = "ipv4"
  security_groups = [
    aws_security_group.guacamole_lb.id
  ]
  subnets = [
    var.common.vpc.subnet_four.id,
    var.common.vpc.subnet_five.id
  ]
  preserve_host_header = "true"
  access_logs {
    enabled = true
    bucket  = "aws-elb-logs-131321883543"
  }
  tags = merge(
    local.tags,
    {
      Name = "Guacamole ALB"
    }
  )
}

resource "aws_lb_listener" "guacamole" {
  # use NLB in prod, else ALB
  load_balancer_arn = var.common.environment == "prod" ? aws_lb.guacamole_nlb["deployed"].arn : aws_lb.guacamole_alb["deployed"].arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.guacamole.arn
  }
  port                                 = "443"
  protocol                             = "HTTPS"
  ssl_policy                           = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn                      = var.certificates.external.arn
  routing_http_response_server_enabled = true
  tags                                 = local.tags
}

resource "aws_lb_target_group" "guacamole" {
  name     = "guacamole"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.common.vpc.id
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 5
    interval            = 30
    matcher             = "200"
    path                = "/guacamole/"
    port                = "8080"
    protocol            = "HTTP"
    timeout             = 5
  }
  target_health_state {
    enable_unhealthy_connection_termination = false
    unhealthy_draining_interval             = 0
  }
  tags = local.tags
}

resource "aws_lb_target_group_attachment" "guacamole" {
  target_group_arn = aws_lb_target_group.guacamole.arn
  target_id        = aws_instance.guacamole.id
  port             = 8080
}

resource "aws_security_group" "guacamole_instance" {
  name        = "guacamole_instance"
  description = "Allow inbound/outbound traffic to the guacamole instance"
  vpc_id      = var.common.vpc.id
  tags        = local.tags
}

resource "aws_vpc_security_group_ingress_rule" "guacamole_instance_allow_8080" {
  security_group_id = aws_security_group.guacamole_instance.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 8080
  to_port           = 8080
}

resource "aws_vpc_security_group_ingress_rule" "guacamole_instance_allow_ssh" {
  security_group_id = aws_security_group.guacamole_instance.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "guacamole_instance_allow_all" {
  security_group_id = aws_security_group.guacamole_instance.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_instance" "guacamole" {
  ami                  = data.aws_ssm_parameter.dot_rhel8_ami.value
  availability_zone    = data.aws_subnet.four.availability_zone
  iam_instance_profile = aws_iam_instance_profile.ec2.name
  # iam_instance_profile = "SDC-Power-User-Role"
  instance_type = "c6a.xlarge"
  key_name      = "ost-sdc-${var.common.environment}"
  vpc_security_group_ids = [
    data.aws_security_group.FMS_managed.id,
    aws_security_group.guacamole_instance.id
  ]
  subnet_id                   = var.common.vpc.subnet_four.id
  user_data                   = data.template_file.user_data.rendered
  user_data_replace_on_change = true
  lifecycle {
    # prevent_destroy = true
    ignore_changes = [
      instance_type,
      root_block_device,
      tags["Name"],
      tags["config_version"],
      tags["git_commit"],
    ]
  }
  tags = merge(
    local.tags,
    {
      Name           = "guacamole",
      Role           = "Guacamole-Server"
      config_version = var.common.config_version
      git_commit     = var.common.git_commit_head_sha1
    }
  )

  # set some defaults to keep rebuilds clean
  hibernation = false
  capacity_reservation_specification {
    capacity_reservation_preference = "open"
  }
  enclave_options {
    enabled = false
  }
  maintenance_options {
    auto_recovery = "default"
  }
  metadata_options {
    http_endpoint               = "enabled"
    http_protocol_ipv6          = "disabled"
    http_put_response_hop_limit = 1
    http_tokens                 = "optional"
    instance_metadata_tags      = "disabled"
  }
  private_dns_name_options {
    enable_resource_name_dns_a_record    = false
    enable_resource_name_dns_aaaa_record = false
    hostname_type                        = "ip-name"
  }
}
