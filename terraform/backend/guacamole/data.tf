data "aws_ssm_parameter" "dot_rhel8_ami" {
  name = "/dot/latest/prod/rhel8-linux-ami"
}

# data "aws_ssm_parameter" "dot_rhel9_ami" {
#   name = "/dot/latest/prod/rhel9-linux-ami"
# }

data "aws_subnet" "four" {
  id = var.common.vpc.subnet_four.id
}

data "aws_security_group" "FMS_managed" {
  // FMS managed security group. This sg is auto attached by ECS to all ec2.
  vpc_id = var.common.vpc.id
  filter {
    name   = "description"
    values = ["FMS managed security group."]
  }
}

data "aws_ssm_parameter" "mariadb_password" {
  name = "guacamole-${var.common.environment}-mariadb-password"
}

data "aws_db_instance" "mariadb" {
  db_instance_identifier = "${var.common.environment}-guacamole"
}
