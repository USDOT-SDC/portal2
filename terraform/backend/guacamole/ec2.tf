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

resource "aws_lb" "guacamole" {
  name               = "guacamole"
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
  tags = local.tags
}

resource "aws_lb_listener" "guacamole" {
  load_balancer_arn = aws_lb.guacamole.arn
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
  target_health_state {
    enable_unhealthy_connection_termination = false
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
  iam_instance_profile = "SDC-Power-User-Role"
  instance_type        = "c6a.xlarge"
  key_name             = "ost-sdc-${var.common.environment}"
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
