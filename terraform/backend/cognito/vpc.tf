resource "aws_vpc_endpoint" "cognito" {
  vpc_id              = var.common.vpc.id
  service_name        = "com.amazonaws.${var.common.region}.cognito-idp"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  # Add additional subnet IDs here for multi-AZ coverage
  subnet_ids         = [var.common.vpc.subnet_four.id]
  security_group_ids = [var.common.vpc.default_security_group.id]

  tags = merge(local.common_tags, {
    Name = "Cognito Interface"
  })
}
